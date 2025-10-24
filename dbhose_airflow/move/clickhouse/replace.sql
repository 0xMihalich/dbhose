with 
    '{table_temp}' as table_temp
  , '{table_dest}' as table_dest
  , partitions as (
    select partition 
    from system.parts 
    where database = splitByChar('.', table_temp)[1]
        and table = splitByChar('.', table_temp)[2]
        and partition <> 'tuple()'
        and active
    order by partition
)
select
    toBool(count() > 0) as is_avaliable
  , if(
        is_avaliable
      , 'alter table ' || table_dest || ' ' ||
        arrayStringConcat(
            arrayMap(
                p -> 'replace partition ' || p || ' from ' || table_temp
              , groupArray(partition)
            ), ', ')
      , '') as move_query
from partitions