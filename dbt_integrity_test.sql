SELECT *
FROM {{ ref('aus_company_data') }}
WHERE abn IS NOT NULL AND abn NOT IN (SELECT abn FROM {{ ref('abr') }})
