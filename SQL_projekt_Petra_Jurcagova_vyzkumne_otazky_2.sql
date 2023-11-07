/*2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech 
cen a mezd?*/

/*vybrání sledovaných položek pro první (2006) a poslední sledované období (2018) a výpočet průměrné ceny za měrnou jednotku*/
SELECT 
name_food,YEAR,AVG(average_wage)average_wage_year, FLOOR(AVG(average_wage)/average_price) amount
FROM 
t_Petra_Jurcagova_project_SQL_primary_final
WHERE 
(name_food LIKE 'Ml%' OR name_food LIKE 'Chl%') AND (year = 2006 OR year = 2018)
GROUP BY 
year,name_food;