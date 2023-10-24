/*Tvorba tabulky t_Petra_Jurcagova_project_SQL_primary_final_2 */

/*Spojení tabulek czechia_payroll a czechia_payroll_industry_branch*/
SELECT 
*
FROM 
czechia_payroll cp JOIN czechia_payroll_industry_branch cpi
ON industry_branch_code = code;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_mzdy_podle_prum_odvetvi AS
(SELECT
*
FROM
czechia_payroll cp JOIN czechia_payroll_industry_branch cpi
ON industry_branch_code = code);

/*Filtrování dat podle mzdy a čistého příjmu*/
/*value_type_code 5958 představuje mzdu a calculation_code 200 je čistá mzda*/
SELECT 
ROUND(AVG(value),0)average_wage,value_type_code, calculation_code, industry_branch_code, payroll_year, name 
FROM 
t_Petra_Jurcagova_mzdy_podle_prum_odvetvi
WHERE 
(value_type_code = 5958 AND calculation_code = 200) AND payroll_year >=2006 AND payroll_year <= 2018
GROUP BY 
value_type_code, calculation_code, industry_branch_code, payroll_year, name 
ORDER BY
payroll_year DESC, average_wage DESC,industry_branch_code DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_Prumerne_mzdy_odvetvi AS
(SELECT 
ROUND(AVG(value),0)average_wage,value_type_code, calculation_code, industry_branch_code, payroll_year, name 
FROM 
t_Petra_Jurcagova_mzdy_podle_odvetvi
WHERE 
(value_type_code = 5958 AND calculation_code = 200) AND payroll_year  >=2006 AND payroll_year <= 2018
GROUP BY 
value_type_code , calculation_code, industry_branch_code, payroll_year, name 
ORDER BY
payroll_year DESC, average_wage DESC, industry_branch_code DESC);

/*výpočet percentuálního meziročního rozdílu mezd*/
SELECT 
o.*, LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year),
ROUND((((average_wage/LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year))-1)*100),1)
FROM
t_Petra_Jurcagova_Prumerne_mzdy_odvetvi o
ORDER BY
o.payroll_year DESC, average_wage DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_pomocna_platy AS 
(SELECT
o.*, LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year)previous_year,
ROUND((((average_wage/LAG(average_wage)OVER(PARTITION BY industry_branch_code ORDER BY payroll_year))-1)*100),1)
interannual_percentage_difference
FROM
t_Petra_Jurcagova_Prumerne_mzdy_odvetvi o
ORDER BY
o.payroll_year DESC, average_wage DESC);

/*příprava pomocných tabulek pro potraviny*/
SELECT
*
FROM
czechia_price cp JOIN czechia_price_category c
ON cp.category_code = c.code

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_ceny_potravin_kategorie_potravin AS
(SELECT
*
FROM
czechia_price cp JOIN czechia_price_category c
ON cp.category_code = c.code);

/*vypočítaná průměrná cena potravin v jednotlivých letech*/
SELECT 
AVG(value), name, extract(YEAR FROM date_from), region_code,category_code
FROM 
t_Petra_Jurcagova_ceny_potravin_kategorie_potravin
GROUP BY
name, extract(YEAR FROM date_from), region_code, category_code
ORDER BY
extract(YEAR FROM date_from)DESC,region_code;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_prumerCenaPotravin_roky AS 
(SELECT 
ROUND(AVG(value),1)average, name, extract(YEAR FROM date_from)year, region_code,category_code
FROM 
t_Petra_Jurcagova_ceny_potravin_kategorie_potravin
GROUP BY
name, extract(YEAR FROM date_from), region_code,category_code
ORDER BY
extract(YEAR FROM date_from)DESC,region_code);

/*vybrání dat - průměrná cena, jméno, rok, kód kategorie*/
SELECT 
ROUND(AVG(average),1)average_price, name, year, category_code
FROM 
t_Petra_Jurcagova_prumerCenaPotravin_roky
GROUP BY
year, name,category_code
ORDER BY 
year DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_Prumerna_cena_za_roky AS 
(SELECT 
ROUND(AVG(average),1)average_price, name, year, category_code
FROM 
t_Petra_Jurcagova_prumerCenaPotravin_roky
GROUP BY
year, name,category_code
ORDER BY 
year DESC);

/*výpočet meziročního procentuálního rozdílu ceny jednotlivých potravin*/
SELECT 
p.*, LAG(average_price)OVER(PARTITION BY category_code ORDER BY year)average_price_last_year,
ROUND((((average_price/LAG(average_price)OVER(PARTITION BY category_code ORDER BY year))-1)*100),1)
interannual_percentage_difference_food
FROM 
t_Petra_Jurcagova_Prumerna_cena_za_roky p
ORDER BY 
category_code DESC,year DESC;

/*vytvoření pomocné tabulky*/
CREATE TABLE t_Petra_Jurcagova_pomocna_Potraviny_2 AS 
(SELECT 
p.*, LAG(average_price)OVER(PARTITION BY category_code ORDER BY year)average_price_last_year,
ROUND((((average_price/LAG(average_price)OVER(PARTITION BY category_code ORDER BY year))-1)*100),1)
interannual_percentage_difference_food
FROM 
t_Petra_Jurcagova_Prumerna_cena_za_roky p
ORDER BY 
category_code DESC,year DESC);

/*spojení pomocných tabulek pro potraviny a mzdy v letech 2018 až 2006*/
SELECT 
p.*, m.*
FROM 
t_Petra_Jurcagova_pomocna_Potraviny_2 p JOIN t_Petra_Jurcagova_pomocna_platy m
ON p.year = m.payroll_year;

/*vytvoření t_Petra_Jurcagova_project_SQL_primary_final_2*/
CREATE TABLE t_Petra_Jurcagova_project_SQL_primary_final_2 AS
(SELECT 
p.average_price, p.name name_food, p.year, p.category_code, p.average_price_last_year, 
p.interannual_percentage_difference_food,m.average_wage, m.industry_branch_code,m.payroll_year, m.name, m.previous_year,
m.interannual_percentage_difference
FROM 
t_Petra_Jurcagova_pomocna_Potraviny_2 p JOIN t_Petra_Jurcagova_pomocna_platy m
ON p.year = m.payroll_year);

/*zobrazení NULL hodnot*/
SELECT 
*
FROM
t_Petra_Jurcagova_project_SQL_primary_final_2
WHERE 
average_price_last_year IS NULL;