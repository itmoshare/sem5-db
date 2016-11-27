IF OBJECT_ID (N'dbo.Saled', N'FN') IS NOT NULL
DROP FUNCTION dbo.Saled;

CREATE FUNCTION dbo.SaledCt ()
RETURNS TABLE
AS
RETURN 
(
SELECT avg(prod_ct)
FROM (
	SELECT departments.id as dep_id, SUM(products.count) as prod_ct
	FROM departments
	INNER JOIN holidays ON departments.id = holidays.department_id
	INNER JOIN products ON holidays.person_id = products.seller_id
	GROUP BY departments.id)
	
);

-- SELECT *
-- FROM dbo.SaledCt() FOR Xml AUTO;

CREATE FUNCTION dbo.IsWorkDay (@val TINYINT)
RETURNS TINYINT
BEGIN
	IF @val = 0
		RETURN 1
	RETURN 0
END

CREATE FUNCTION dbo.DaysWorked (@person_id INT)
RETURNS INT
BEGIN
	DECLARE @res INT
	SELECT
		@res = sum((dbo.IsWorkDay(day_1) + 
			dbo.IsWorkDay(day_2) + 
			dbo.IsWorkDay(day_3) + 
			dbo.IsWorkDay(day_4) + 
			dbo.IsWorkDay(day_5) + 
			dbo.IsWorkDay(day_6) + 
			dbo.IsWorkDay(day_7) + 
			dbo.IsWorkDay(day_8) + 
			dbo.IsWorkDay(day_9) + 
			dbo.IsWorkDay(day_10) + 
			dbo.IsWorkDay(day_11) + 
			dbo.IsWorkDay(day_12) + 
			dbo.IsWorkDay(day_13) + 
			dbo.IsWorkDay(day_14) + 
			dbo.IsWorkDay(day_15) + 
			dbo.IsWorkDay(day_16) + 
			dbo.IsWorkDay(day_17) + 
			dbo.IsWorkDay(day_18) + 
			dbo.IsWorkDay(day_19) + 
			dbo.IsWorkDay(day_20) + 
			dbo.IsWorkDay(day_21) + 
			dbo.IsWorkDay(day_22) + 
			dbo.IsWorkDay(day_23) + 
			dbo.IsWorkDay(day_24) + 
			dbo.IsWorkDay(day_25) + 
			dbo.IsWorkDay(day_26) + 
			dbo.IsWorkDay(day_27) + 
			dbo.IsWorkDay(day_28) + 
			dbo.IsWorkDay(day_29) +
			dbo.IsWorkDay(day_30)))
	FROM dbo.holidays
	WHERE person_id = @person_id
	GROUP BY person_id;
	RETURN @res;
END

CREATE FUNCTION dbo.CalcSalary ()
RETURNS TABLE
AS
RETURN
(
	select *
	from (select people.firstname,
		people.lastname,
		people.middlename,
		dbo.DaysWorked(people.id) * salary.salary_day as sal
		from people
		inner join salary on salary.person_id = people.id) as a
	where a.sal IS NOT NULL
)

--SELECT * from dbo.CalcSalary()
--FOR Xml AUTO;

