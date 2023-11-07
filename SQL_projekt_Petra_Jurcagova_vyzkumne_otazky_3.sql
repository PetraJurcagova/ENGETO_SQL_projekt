/*3.Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*/
/*průměrný meziroční procentuální nárůst cen potravin v letech 2006 až 2018*/
SELECT 
ROUND(AVG(Sub.interannual_percentage_difference_food),1)price_increase,Sub.name_food
FROM
(SELECT 
DISTINCT name_food,category_code, interannual_percentage_difference_food,year
FROM 
t_Petra_Jurcagova_project_SQL_primary_final)Sub
GROUP BY
Sub.name_food
ORDER BY 
price_increase;