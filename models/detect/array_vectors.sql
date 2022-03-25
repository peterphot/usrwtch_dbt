{{ config(materialized='table', schema='detect') }}

select
  session_id 
  , source_ip
  , array_agg(user_event order by user_event asc) as event_name_vector
  , array_agg(prop_interaction order by user_event asc) as prop_vector
  , array_agg(n order by user_event asc) as v_vector
from {{ ref('interaction_vectors') }}
where true
group by 1,2