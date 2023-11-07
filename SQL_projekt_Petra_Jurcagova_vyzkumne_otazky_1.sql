/*1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*/
/*výpočet průměrného meziročního percentuálního rozdílu mezd v období 2018 až 2006*/
SELECT 
DISTINCT(name),payroll_year, average_wage,previous_year, (average_wage - previous_year) interannual_difference
FROM 
t_Petra_Jurcagova_project_SQL_primary_final
WHERE 
(average_wage - previous_year) < 0
ORDER BY 
payroll_year DESC;

/*SELECT 
name, ROUND(AVG(interannual_percentage_difference),1)average_wage_growth
FROM 
t_Petra_Jurcagova_project_SQL_primary_final
GROUP BY
name
ORDER BY
average_wage_growth;*/