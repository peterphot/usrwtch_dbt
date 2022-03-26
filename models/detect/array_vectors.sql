{{ config(materialized='table', schema='detect') }}

select
  session_id 
  , source_ip
  , session_start_local_time
  , array_agg(user_event order by user_event asc) as event_name_vector
  , array_agg(cast(prop_interaction as float) order by user_event asc) as prop_vector
  , array_agg(n order by user_event asc) as n_vector
from {{ ref('interaction_vectors') }}
where true
group by 1,2,3