CREATE OR REPLACE FUNCTION load_master_table()
RETURNS void AS
$$
BEGIN
    -- Drop existing table if present
    DROP TABLE IF EXISTS master_table;

    -- Create the new master table
    CREATE TABLE master_table (
        learner_id TEXT,
        opportunity_id TEXT,
        assigned_cohort TEXT,
        apply_date DATE,
        status TEXT,

        standardized_degree TEXT,
        standardized_institution TEXT,
        standardized_major TEXT,
        standardized_country TEXT,

        opportunity_name TEXT,
        category TEXT,
        opportunity_code TEXT,

        start_date_extracted DATE,
        end_date_extracted DATE,
        size TEXT,
        cohort_default TEXT
    );

    -- Insert cleaned and joined data
    INSERT INTO master_table
    SELECT 
        lop.learner_id,
        lop.opportunity_id,
        lop.assigned_cohort,
        lop.apply_date,
        lop.status,

        u.standardized_degree,
        u.standardized_institution,
        u.standardized_major,
        u.standardized_country,

        o.opportunity_name,
        o.category,
        o.opportunity_code,

        c.start_date_extracted,
        c.end_date_extracted,
        c.size,
        c.cohort_default
    FROM learner_opportunity_cleaned lop
    LEFT JOIN user_data_cleaned u 
        ON TRIM(LOWER(REPLACE(lop.learner_id, 'Learner#', ''))) = 
           TRIM(LOWER(REPLACE(u.learner_id, 'Learner#', '')))
    LEFT JOIN opportunity_cleaned o 
        ON TRIM(LOWER(REPLACE(lop.opportunity_id, 'Opportunity#', ''))) = 
           TRIM(LOWER(REPLACE(o.opportunity_id, 'Opportunity#', '')))
    LEFT JOIN cohort_cleaned_final c 
        ON TRIM(LOWER(lop.assigned_cohort)) = 
           TRIM(LOWER(c.assigned_cohort));

END;
$$ LANGUAGE plpgsql;
