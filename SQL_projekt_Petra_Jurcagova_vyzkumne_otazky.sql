/*SADA SQL PRO ODPOVĚZENÍ VÝZKUMNÝCH OTÁZEK*/

/*1.Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?*/
SELECT 
*
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2;

/*výpočet průměrného meziročního percentuálního rozdílu mezd v období 2018 až 2006*/
SELECT 
name, ROUND(AVG(interannual_percentage_difference),1)average_wage_growth
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2
GROUP BY
name
ORDER BY
average_wage_growth;

/*2.Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech 
cen a mezd?*/

/*vybrání sledovaných položek pro první (2006) a poslední sledované období (2018) a výpočet průměrné ceny za měrnou jednotku*/
SELECT 
name_food,YEAR,AVG(average_wage)average_wage_year, FLOOR(AVG(average_wage)/average_price) amount
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2
WHERE 
(name_food LIKE 'Ml%' OR name_food LIKE 'Chl%') AND (year = 2006 OR year = 2018)
GROUP BY 
year,name_food;

/*3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*/

/*průměrný meziroční procentuální nárůst cen potravin v letech 2006 až 2018*/
SELECT 
ROUND(AVG(Sub.interannual_percentage_difference_food),1)price_increase,Sub.name_food
FROM
(SELECT 
DISTINCT name_food,category_code, interannual_percentage_difference_food,year
FROM 
t_Petra_Jurcagova_project_SQL_primary_final_2)Sub
GROUP BY
Sub.name_food
ORDER BY 
price_increase;
 
/*4.Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*/

/*nárůst cen potravin a výše mezd v rámci meziročního percentuálního rozdílu v letech 2006 až 2018*/
SELECT 
ROUND(AVG(interannual_percentage_difference_food),1)food, ROUND(AVG(interannual_percentage_difference),1)wage, payroll_year
FROM
t_Petra_Jurcagova_project_SQL_primary_final_2
GROUP BY
payroll_year DESC;

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
t_Petra_Jurcagova_project_SQL_primary_final_2
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
