{{ config(materialized='table', schema='detect') }}

with distinct_events as (
    select distinct
        doc_path
        , user_event
    from {{ ref('fact_event_sessions') }}
    where True
), distinct_sessions as (
    select distinct
        session_id
        , source_ip
        , min(local_time) as session_start_local_time
    from {{ ref('fact_event_sessions') }}
    where True
    group by 1, 2
), empty_vectors as (
    select
        *
    from distinct_sessions ds
    join distinct_events de
        on True
), prep as (
    select
        ev.session_id
        , ev.source_ip
        , ev.doc_path
        , ev.user_event
        , ev.session_start_local_time
        , count(fes.user_event) as n
    from empty_vectors ev
    left join {{ ref('fact_event_sessions') }} fes
        on ev.session_id = fes.session_id
            and ev.source_ip = fes.source_ip
            and ev.doc_path = fes.doc_path
            and ev.user_event = fes.user_event
    group by 1,2,3,4,5
)


select
    session_id
    , source_ip
    , session_start_local_time
    , doc_path
    , user_event
    , n
    , sum(n) over(partition by session_id, source_ip) as n_session_events
    , n/sum(n) over(partition by session_id, source_ip) as prop_interaction
from prep    