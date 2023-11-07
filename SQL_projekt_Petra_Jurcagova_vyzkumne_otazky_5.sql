/*5.Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji
v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?*/
/*z tabulky secondary_final vybrání dat pro ČR*/
SELECT 
*
FROM 
t_Petra_Jurcagova_project_SQL_secondary_final
WHERE 
country LIKE 'Cz%'
ORDER BY 
YEAR DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_percantage_difference AS
(SELECT 
ROUND(AVG(interannual_percentage_difference_food),1)food, ROUND(AVG(interannual_percentage_difference),1)wage, payroll_year
FROM
t_Petra_Jurcagova_project_SQL_primary_final
GROUP BY
payroll_year DESC);

/*srovnání dat pro ČR mezi lety 2006 až 2018, HDP, gini koeficientem,
populací a meziročním percentuálním rozdílem HDP, cen potravim a mezd*/
SELECT 
Sc.YEAR,Sc.country,Sc.HDP,Sc.gini,Sc.population,Sc.HDP_last_year, Sc.interannual_percentage_difference HDP_percentage_difference,
Pf.food,Pf.wage,Pf.payroll_year
FROM 
t_Petra_Jurcagova_project_SQL_secondary_final Sc JOIN t_Petra_Jurcagova_percantage_difference Pf
ON Sc.YEAR = Pf.payroll_year
WHERE 
country LIKE 'Cz%'
ORDER BY 
payroll_year DESC;
