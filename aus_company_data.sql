%sql
WITH australian_websites AS (
    SELECT
        id,
        url,
        LOWER(TRIM(company_name)) AS company_name_clean,
        title,
        description,
        LOWER(TRIM(industry)) AS industry_clean,
        email_id,
        contact_no,
        social_links,
        snapshot_date
    FROM
        {{ ref('australian_websites') }}
),

abr AS (
    SELECT
        abn,
        LOWER(TRIM(business_name)) AS business_name_clean,
        state,
        postcode,
        source
    FROM
        {{ ref('abr') }}
)

-- Create the integrated view of company data
SELECT
    COALESCE(aw.company_name_clean, ab.business_name_clean) AS company_name,
    aw.url AS website_url,
    ab.abn,
    aw.industry_clean AS industry,
    aw.email_id,
    aw.contact_no,
    ab.state,
    ab.postcode
FROM
    australian_websites aw
LEFT JOIN
    abr ab
ON
    aw.company_name_clean = ab.business_name_clean;
