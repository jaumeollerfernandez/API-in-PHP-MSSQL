SELECT 
    session_id, 
    command, 
    percent_complete, 
    status, 
    wait_type, 
    wait_time, 
    last_wait_type, 
    blocking_session_id, 
    wait_resource, 
    cpu_time, 
    total_elapsed_time 
FROM 
    sys.dm_exec_requests 
WHERE 
    database_id = DB_ID('WS_API_07');
