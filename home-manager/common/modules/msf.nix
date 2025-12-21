{ ...
}:
{
  home.file.".msf4/database.yml".text = ''
    # To set up a metasploit database, follow the directions hosted at:
    # http://r-7.co/MSF-DEV#set-up-postgresql
    development: &pgsql
        adapter: postgresql
        database: msf 
        username: msf
        password: msf 
        host: localhost
        port: 5432
        pool: 200
        timeout: 5

    # You will often want to seperate your databases between dev
    # mode and prod mode. Absent a production db, though, defaulting
    # to dev is pretty sensible for many developer-users.
    production: &production
      <<: *pgsql
  '';
}
