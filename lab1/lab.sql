1.

ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY HH24:MI:SS';
SELECT * FROM Н_СЕССИЯ;

2.

select distinct(НАИМЕНОВАНИЕ) from Н_ДИСЦИПЛИНЫ;

3.

with rnd_person as (select дата_рождения 
                    from (select дата_рождения from н_люди 
                          order by dbms_random.random) 
                    where rownum=1)
select дата_рождения, to_date('2016/09/1', 'yyyy/mm/dd') - to_date(дата_рождения) as разность 
from rnd_person;

4.

with rnd_person as (select дата_рождения 
                    from (select дата_рождения from н_люди 
                          order by dbms_random.random) 
                    where rownum=1)
select фамилия||' '||substr(имя,0,1)||'.'||substr(отчество,0,1)||'.' as ФИО, н_люди.дата_рождения 
from н_люди, rnd_person
where Extract(month from н_люди.дата_рождения) = Extract(month from rnd_person.дата_рождения);

5.

with rnd_person as (select фамилия 
					from (select фамилия from н_люди
						  order by dbms_random.random)
					where rownum=1)
select н_люди.фамилия, имя, отчество, ид
from н_люди, rnd_person
where substr(н_люди.фамилия,0, 2) = substr(rnd_person.фамилия, 0, 2)
      AND ROWNUM <= 75
      ORDER BY ФАМИЛИЯ DESC, ИМЯ DESC, ОТЧЕСТВО DESC;

6.

select фамилия, имя, отчество, ид from н_люди
where substr(имя,0,1) not in('А','Б','З')
	  and substr(отчество,0,1) not in('К','У');

select фамилия, имя, отчество, ид from н_люди
where regexp_like(имя, '^[^АБЗ]*$') and
      regexp_like(отчество, '^[^КУ]*$');

7.

with rnd_person as (select имя 
                    from (select имя from н_люди 
                          order by dbms_random.random) 
                    where rownum=1)
select count(н_люди.ид)
from н_люди, rnd_person
where н_люди.имя = rnd_person.имя;

8.

with rnd_person as (select ид 
					from (select н_люди.ид 
						  from н_люди inner join н_ведомости on н_люди.ид = н_ведомости.члвк_ид
						  order by dbms_random.random) 
					where rownum = 1)
select 2*оценка as удв_оценка
from н_ведомости join rnd_person on rnd_person.ид = н_ведомости.члвк_ид 
where regexp_like(оценка, '^[0-5]$')
      and оценка not in ('0','1');

9.

with rnd_pers as (select ид 
                  from (select н_люди.ид 
                        from н_люди inner join н_ведомости on н_люди.ид = н_ведомости.члвк_ид
                        order by dbms_random.random) 
                  where rownum <= 7)
select sum(н_ведомости.оценка)
from н_ведомости inner join rnd_pers on н_ведомости.члвк_ид = rnd_pers.ид
where н_ведомости.оценка in ('2', '3', '4', '5');

10.

select * from н_люди, н_ученики;


11.

select фамилия, имя, отчество, avg_mark 
from (select фамилия, имя, отчество, avg_mark
      from (select фамилия, имя, отчество, avg_mark, max(avg_mark) over (partition by фамилия order by avg_mark desc) as max_in_group
            from (select avg(оценка) as avg_mark, н_люди.ид as члвк_ид
                  from н_люди join н_ведомости on н_ведомости.члвк_ид=н_люди.ид
                  where оценка in ('2','3','4','5')
                  group by н_люди.ид)
            join н_люди on н_люди.ид=члвк_ид)
      where avg_mark != max_in_group
      order by dbms_random.random)
where rownum<=7;

12.

select 'Оценки 4 и 5 во всем университете',
	to_char(round(avg(оценка),1)) as "Средняя оценка",
	to_char(count(оценка)) as "Количество оценок"
from н_ведомости
where оценка in('4','5')
union all
select 'Оценки «зачет» в произвольном учебном году во всем университете',
	to_char('-') as "Средняя оценка",
	to_char(count(оценка)) as "Количество оценок"
from н_ведомости
where дата between to_date('2015/09/01', 'yyyy/mm/dd')
	and to_date('2016/06/20', 'yyyy/mm/dd')
    and оценка = 'зачет'
union all
select 'Расстояние Левенштайна до вашей фамилии от фамилий 10 персон, имеющих оценки 3, 4 и 5',
	to_char(utl_match.edit_distance('Мохнаткин', фамилия)) as "Средняя оценка",
	to_char('-') as "Количество оценок"
from (select фамилия 
      from (select distinct н_люди.ид, фамилия
            from н_люди inner join н_ведомости on н_люди.ид = н_ведомости.члвк_ид
            where оценка in ('3','4','5')
            order by dbms_random.random)
      where rownum <= 10);


13.

SELECT ФАМИЛИЯ, ИМЯ, ОТЧЕСТВО FROM Н_ЛЮДИ
WHERE ИД IN (SELECT ЧЛВК_ИД FROM Н_ВЕДОМОСТИ
			 WHERE ОЦЕНКА IN('3','4') AND 
				   ДАТА BETWEEN TO_DATE('2015/09/01', 'yyyy/mm/dd') 
				   AND TO_DATE('2016/07/20', 'yyyy/mm/dd')
			 GROUP BY ЧЛВК_ИД)
ORDER BY ФАМИЛИЯ, ИМЯ, ОТЧЕСТВО;

14.
create or replace function sum_digits(val in number) return number 
is    
    val_length number := length(val);
    val_sum number;
begin
    val_sum := 0;
    for i in 1 .. val_length
    loop
      val_sum := val_sum + substr(val, i, 1);
    end loop;
    return(val_sum);
end;
/

with rnd_sum as (select sum_digits(ид) as s
                 from (select н_люди.ид 
                       from н_люди
                       order by dbms_random.random) 
                 where rownum = 1),
    n_un_fio as (select ид
                 from (select фамилия, имя, отчество, ид,
                       count(ид) over (partition by фамилия, имя, отчество) as ct_fullname
                       from н_люди)
                 where ct_fullname > 1),
    mark_sum as (select члвк_ид, sum(оценка) as s
                 from н_ведомости
                 where оценка in ('2','3','4','5')
                 group by члвк_ид)
select фамилия, имя, отчество, н_люди.ид, mark_sum.s
from н_люди
inner join n_un_fio on н_люди.ид = n_un_fio.ид
inner join mark_sum on н_люди.ид = mark_sum.члвк_ид
cross join rnd_sum
where mark_sum.s <= rnd_sum.s;