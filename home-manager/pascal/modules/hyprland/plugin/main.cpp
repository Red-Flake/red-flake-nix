#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/desktop/view/Window.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/protocols/XDGShell.hpp>
#include <hyprland/src/xwayland/XSurface.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/managers/EventManager.hpp>
#include <hyprland/src/config/shared/actions/ConfigActions.hpp>
#include <nlohmann/json.hpp>
#include <map>
#include <sstream>
// The per-toplevel decoration maps are private; plugins build against these exact headers.
#define private public
#include <hyprland/src/protocols/XDGDecoration.hpp>
#include <hyprland/src/protocols/ServerDecorationKDE.hpp>
#undef private
#include "appmenu.h"

namespace {
struct Menu {
    WP<CWLSurfaceResource> surface;
    std::string service, path;
};
std::map<wl_resource*, Menu> menus;
std::vector<wl_resource*> managers;
std::map<uintptr_t, CHyprSignalListener> windowListeners;
CHyprSignalListener opened, closed;
wl_global* global = nullptr;
SP<SHyprCtlCommand> metadataCommand;
SP<SHyprCtlCommand> maximizedCommand;

void release(wl_client*, wl_resource* resource) { wl_resource_destroy(resource); }
void setAddress(wl_client*, wl_resource* resource, const char* service, const char* path) {
    auto& menu = menus.at(resource);
    menu.service = service;
    menu.path = path;
}
const struct org_kde_kwin_appmenu_interface menuImpl = {setAddress, release};
void createMenu(wl_client* client, wl_resource* manager, uint32_t id, wl_resource* surface) {
    auto resource = wl_resource_create(client, &org_kde_kwin_appmenu_interface, wl_resource_get_version(manager), id);
    if (!resource) { wl_client_post_no_memory(client); return; }
    menus.emplace(resource, Menu{CWLSurfaceResource::fromResource(surface), {}, {}});
    wl_resource_set_implementation(resource, &menuImpl, nullptr, [](wl_resource* r) { menus.erase(r); });
}
const struct org_kde_kwin_appmenu_manager_interface managerImpl = {createMenu, release};
void bindManager(wl_client* client, void*, uint32_t version, uint32_t id) {
    auto resource = wl_resource_create(client, &org_kde_kwin_appmenu_manager_interface, std::min(version, 2u), id);
    if (!resource) { wl_client_post_no_memory(client); return; }
    managers.push_back(resource);
    wl_resource_set_implementation(resource, &managerImpl, nullptr, [](wl_resource* r) { std::erase(managers, r); });
}
// Wayland clients without a server-side decoration request draw their own titlebar.
// Qt asks through xdg-decoration, GTK3 (e.g. LibreOffice) through KDE's server-decoration protocol.
bool drawsOwnTitlebar(PHLWINDOW window) {
    if (window->m_isX11 || !window->m_xdgSurface || !window->m_xdgSurface->m_toplevel)
        return false;
    const auto toplevel = window->m_xdgSurface->m_toplevel.lock();
    for (const auto& [resource, decoration] : PROTO::xdgDecoration->m_decorations) {
        if (CXDGToplevelResource::fromResource(resource) == toplevel)
            return decoration->mostRecentlyRequested == ZXDG_TOPLEVEL_DECORATION_V1_MODE_CLIENT_SIDE;
    }
    const auto surface = window->m_xdgSurface->m_surface.lock();
    for (const auto& decoration : PROTO::serverDecorationKDE->m_decos) {
        if (surface && decoration->m_surf == surface)
            return decoration->m_mostRecentlyRequested != ORG_KDE_KWIN_SERVER_DECORATION_MODE_SERVER;
    }
    return true;
}

void watch(PHLWINDOW window) {
    if (drawsOwnTitlebar(window))
        (void)Config::Actions::tag("+stellaris-csd", window);
    // Hyprland reports every new toplevel as maximized (a tiling default). Floating windows
    // are not, and apps that believe otherwise ignore their own maximize requests.
    if (window->m_isFloating && !window->isFullscreen() && !window->m_isX11 && window->m_xdgSurface && window->m_xdgSurface->m_toplevel)
        window->m_xdgSurface->m_toplevel->setMaximized(false);
    PHLWINDOWREF weak = window;
    auto changed = [weak]() {
        auto w = weak.lock();
        if (!w || !w->m_isMapped) return;
        auto minimize = w->m_isX11 ? w->m_xwaylandSurface->m_state.requestsMinimize : w->m_xdgSurface->m_toplevel->m_state.requestsMinimize;
        if (minimize.has_value())
            g_pEventManager->postEvent({"stellarisminimize", std::format("0x{:x},{}", reinterpret_cast<uintptr_t>(w.get()), *minimize ? 1 : 0)});
        // Hyprland ignores these (suppress_event = "maximize"); the daemon maximizes KDE-style.
        auto maximize = w->m_isX11 ? w->m_xwaylandSurface->m_state.requestsMaximize : w->m_xdgSurface->m_toplevel->m_state.requestsMaximize;
        if (maximize.has_value())
            g_pEventManager->postEvent({"stellarismaximize", std::format("0x{:x},{}", reinterpret_cast<uintptr_t>(w.get()), *maximize ? 1 : 0)});
    };
    if (window->m_isX11 && window->m_xwaylandSurface)
        windowListeners[reinterpret_cast<uintptr_t>(window.get())] = window->m_xwaylandSurface->m_events.stateChanged.listen(changed);
    else if (window->m_xdgSurface && window->m_xdgSurface->m_toplevel)
        windowListeners[reinterpret_cast<uintptr_t>(window.get())] = window->m_xdgSurface->m_toplevel->m_events.stateChanged.listen(changed);
}
}
APICALL EXPORT std::string PLUGIN_API_VERSION() { return HYPRLAND_API_VERSION; }
APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    if (std::string(__hyprland_api_get_hash()) != __hyprland_api_get_client_hash())
        throw std::runtime_error("Stellaris plugin: Hyprland version mismatch");
    global = wl_global_create(g_pCompositor->m_wlDisplay, &org_kde_kwin_appmenu_manager_interface, 2, nullptr, bindManager);
    if (!global) throw std::runtime_error("Cannot register application menu protocol");
    opened = Event::bus()->m_events.window.open.listen(watch);
    closed = Event::bus()->m_events.window.close.listen([](PHLWINDOW w) { windowListeners.erase(reinterpret_cast<uintptr_t>(w.get())); });
    for (auto& w : g_pCompositor->m_windows) if (w->m_isMapped) watch(w);
    metadataCommand = HyprlandAPI::registerHyprCtlCommand(handle, {"stellaris:windows", true, [](eHyprCtlOutputFormat, std::string) {
        nlohmann::json result = nlohmann::json::object();
        for (auto& w : g_pCompositor->m_windows) {
            if (!w->m_isMapped) continue;
            const auto address = std::format("0x{:x}", reinterpret_cast<uintptr_t>(w.get()));
            if (w->m_isX11 && w->m_xwaylandSurface) result[address]["xid"] = w->m_xwaylandSurface->m_xID;
            // Space decorations such as the hyprbars titlebar reserve around the window.
            const auto reserved = w->getFullWindowReservedArea();
            result[address]["reserved"] = {reserved.topLeft.x, reserved.topLeft.y, reserved.bottomRight.x, reserved.bottomRight.y};
        }
        for (const auto& [resource, menu] : menus) {
            auto surface = menu.surface.lock();
            if (!surface || menu.service.empty() || menu.path.empty()) continue;
            auto window = g_pCompositor->getWindowFromSurface(surface);
            if (window) result[std::format("0x{:x}", reinterpret_cast<uintptr_t>(window.get()))]["menu"] = {menu.service, menu.path};
        }
        return result.dump();
    }});
    // `hyprctl stellaris:maximized <address> <0|1>`: tell an app about the daemon's
    // KDE-style maximize, so its own buttons and restore requests match.
    maximizedCommand = HyprlandAPI::registerHyprCtlCommand(handle, {"stellaris:maximized", false, [](eHyprCtlOutputFormat, std::string request) -> std::string {
        std::istringstream words(request);
        std::string command, address, state;
        words >> command >> address >> state;
        for (auto& w : g_pCompositor->m_windows) {
            if (!w->m_isMapped || std::format("0x{:x}", reinterpret_cast<uintptr_t>(w.get())) != address)
                continue;
            if (w->m_isX11 || !w->m_xdgSurface || !w->m_xdgSurface->m_toplevel)
                return "ok";
            w->m_xdgSurface->m_toplevel->setMaximized(state == "1");
            return "ok";
        }
        return "error: no such window";
    }});
    return {"stellaris-desktop", "Native minimize and application menus", "Stellaris", "1"};
}
APICALL EXPORT void PLUGIN_EXIT() {
    opened.reset(); closed.reset(); windowListeners.clear();
    while (!menus.empty()) wl_resource_destroy(menus.begin()->first);
    while (!managers.empty()) wl_resource_destroy(managers.back());
    if (global) wl_global_destroy(global);
    global = nullptr;
}
