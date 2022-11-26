# Partitioned/Managed Partitioned Array  database schema in terms of http/https


* Unrefined notes at the moment
* A blueprint for a partitioned array database http/https database layer
* Last revised: 10/25/2022 05:37AM



`(And presenting an abstracted layout of the Partitioned/Managed Partitoned Array Data Structure Algorithm)`



## Synopsis

The total base routes are as follows: 


* `POST https://{domain_name}:{port}/:database_name/:file_partition_id/:db_archive_id/...` (*base route A*)
* `POST https://{domain_name}:{port}/:database_name/:file_partition_id/:db_archive_id/:db_partition_id...`
    *  (*base route AB)
 * `POST https://{domain_name}:{port}/:database_name/...` #=> For operations that only need to know the database name itself; *base route C)
* domain_name: the server's domain name or IP address
* port: the network port or 80 by default
* :database_name: The name of the configured and existing database
* :file_partition_id : the partition in the array; in the case with the below screenshot, the file partition id is some partition within `url_slice[x]`, where `x` is some `integer`. An example of the partitions that divide out the `data array`, are the files such as
    * url_slice[0]_part_1.json
    * url_slice[0]_part_0.json
    * …




The below screenshot of a diagram of the database structure, which is divided into`url_shorten`, which is `:database_name` in this case. It is the parent folder of the entire database and holds its structure


`url_slice[0]` in this case, where we pay attention to the `url_slice` portion at first would be the primary `:file_partition_id`. But the file partition name is `"abstracted"` from requests because it is an internal string constant, which is pre-defined for the database and is required to hold the structure



[]([Code_z2rwmXzUSu.png (544×1128) ![(hudl.ink)](https://hudl.ink/screens/Code_z2rwmXzUSu.png "(hudl.ink)")
For operations that require `all the database variables` of the database to work

EX: `get, set`


`POST https://{domain_name}:{port}/:database_name/...` #=> For operations that only need to know the **database name** itself; *base route B)

EX:` add`, `database admin operations` (which could also take more of the db server variables)


(Route written somewhat in the style of Sinatra routes, but this server will use Roda)


Where` {domain_name}` and `{port}` are pre-defined constants in the server


* `:database_name` # =>  Main `name of the database`, much like how in `SQL` servers the database has a `"name"` for itself, which is usually a hard-coded word acting as an id



`https://{server_domain_name}:{port}/{original_database_name}/:file_partition_id_string/:db_archive_id(Integer)/:db_partition_id(Integer)/get/...`


`.../get/find/?json_search_hash = #JSON HASH`


`.../get/multi/?ids_to_get_json_arr=[0,2,3,4,5,...]` #=> returns JSON data in the same order that the array for ids are set


`.../get/:id` #=> partition_hash, that has all the data on the entry, or returns a sort of empty hash; every server response consists of a hash that needs to be JSON parsed, because they are JSON data


`...https://hudl.ink:port/:database_name/:add`


`.../add/?entry_to_add_json=` JSON HASH


`.../delete/:id` # => may not return anything; or a false if there was nothing to delete. I dunno


`https://server:port/:database_name/:file_partition_id/:db_archive_id/…`


`set`

`.../set/:id/?set_id_to={json data}`





# getting and setting class variables

`.../get/class_var/:class_var_name`


`.../set/class_var/:class_name`
