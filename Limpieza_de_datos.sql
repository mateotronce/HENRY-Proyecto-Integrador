-- Creo la base de datos
create database Proyecto_Integrador;

use Proyecto_Integrador;

-- Creo La tabla y cargo los datos
create table if not exists GGAL
(
Fecha Date not null primary key,
Apertura float,
Maximo float,
Bajo float,
Cierre float,
Adj_cierre float,
Volumen Int
); 

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\GGAL.csv'
INTO TABLE `GGAL` 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1
LINES (Fecha,Apertura,Maximo,Bajo,Cierre,Adj_cierre,Volumen);
select * from ggal;

-- calculo del promedio
select avg(Apertura),avg(Maximo),avg(Bajo),avg(Cierre) from GGAL;

-- calculo de sigma para la poblacion total
select sqrt(sum(power(Apertura - p.PromA,2))/count(Fecha)) as sigma_A , 
	   sqrt(sum(power(Maximo- p.PromM,2))/count(Fecha)) sigma_M , 
      sqrt(sum(power(Bajo - p.PromB,2))/count(Fecha)) sigma_B, 
      sqrt(sum(power(Cierre - p.PromC,2))/count(Fecha)) sigma_C
from ggal g 
join (select avg(Apertura) as PromA,avg(Maximo) as PromM ,avg(Bajo) as PromB,avg(Cierre) AS PromC from GGAL) as p;

-- filtrado por 3 * sigma
SELECT g.Apertura, g.Maximo, g.Bajo, g.Cierre
FROM GGAL g
JOIN (
    SELECT SQRT(SUM(POWER(Apertura - p.PromA, 2))/COUNT(Fecha)) AS sigma_A,
    SQRT(SUM(POWER(Maximo - p.PromM, 2))/COUNT(Fecha)) AS sigma_M,
    SQRT(SUM(POWER(Bajo - p.PromB, 2))/COUNT(Fecha)) AS sigma_B,
    SQRT(SUM(POWER(Cierre - p.PromC, 2))/COUNT(Fecha)) AS sigma_C,
    p.PromA,
    p.PromM,
    p.PromB, 
    p.PromC
    FROM GGAL g
    JOIN (SELECT AVG(Apertura) AS PromA, AVG(Maximo) AS PromM, AVG(Bajo) AS PromB, AVG(Cierre) AS PromC FROM GGAL) AS p
    GROUP BY p.PromA, p.PromM, p.PromB, p.PromC
) AS sig ON 1=1
WHERE (g.Apertura > (sig.PromA + 3 * sig.sigma_A)) 
OR (g.Bajo > (sig.PromB + 3 * sig.sigma_B)) 
or (g.Maximo > (sig.PromM + 3 * sig.sigma_M)) 
or (g.Cierre > (sig.PromC + 3 * sig.sigma_C));

-- elimino los datos (ya usada) la pongo en comentarios porque el pormedio varia si la vuelvo a aplicar, 
-- se soluciona si la primera vez que se aplica se generan variables globales con el valor del promedio
# DELETE FROM GGAL
# WHERE (Apertura > (SELECT PromA + 3 * sigma_A FROM (SELECT AVG(Apertura) AS PromA FROM GGAL) AS p, (SELECT SQRT(SUM(POWER(Apertura - PromA, 2))/COUNT(Fecha)) AS sigma_A FROM GGAL, (SELECT AVG(Apertura) AS PromA FROM GGAL) AS p) AS s))
#  OR (Bajo > (SELECT PromB + 3 * sigma_B FROM (SELECT AVG(Bajo) AS PromB FROM GGAL) AS p, (SELECT SQRT(SUM(POWER(Bajo - PromB, 2))/COUNT(Fecha)) AS sigma_B FROM GGAL, (SELECT AVG(Bajo) AS PromB FROM GGAL) AS p) AS s))
#  OR (Maximo > (SELECT PromM + 3 * sigma_M FROM (SELECT AVG(Maximo) AS PromM FROM GGAL) AS p, (SELECT SQRT(SUM(POWER(Maximo - PromM, 2))/COUNT(Fecha)) AS sigma_M FROM GGAL, (SELECT AVG(Maximo) AS PromM FROM GGAL) AS p) AS s))
#  OR (Cierre > (SELECT PromC + 3 * sigma_C FROM (SELECT AVG(Cierre) AS PromC FROM GGAL) AS p, (SELECT SQRT(SUM(POWER(Cierre - PromC, 2))/COUNT(Fecha)) AS sigma_C FROM GGAL, (SELECT AVG(Cierre) AS PromC FROM GGAL) AS p) AS s));

-- Exporto el archivo
SELECT Fecha ,
Apertura ,
Maximo ,
Bajo ,
Cierre ,
Adj_cierre ,
Volumen
INTO OUTFILE 'GGAL_SIN_OUT.csv'
FIELDS TERMINATED BY ',' -- Opcional: especifica el separador de campo (por defecto es una coma)
LINES TERMINATED BY '\n' -- Opcional: especifica el separador de línea (por defecto es un salto de línea)
FROM GGAL;









