/*4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*/
/*nárůst cen potravin a výše mezd v rámci meziročního percentuálního rozdílu v letech 2006 až 2018*/
SELECT 
ROUND(AVG(interannual_percentage_difference_food),1)food, ROUND(AVG(interannual_percentage_difference),1)wage, payroll_year
FROM
t_Petra_Jurcagova_project_SQL_primary_final
GROUP BY
payroll_year DESC;