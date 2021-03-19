do $$
	declare 
		v_cdate date = cast('2011-06-01' as date);
		v_date_from date = v_cdate - INTERVAL '6 Month'; 
		v_date_to date = v_cdate + INTERVAL '3 Month'; 
		minInvoice int = 4; --#{4:—D—Ç, 1:‘S‘Ì}
		
begin
	drop table if exists w_ids;
	create table w_ids as
		select
			CustomerID
		from v_ec_trans
		where CustomerID is not null
			and UnitPrice > 0
			and invoiceDate >= v_date_from
			and invoiceDate < v_cdate
		group by CustomerID
		having count(distinct invoiceNo) >= minInvoice
	;
	
	drop table if exists w_ids_kept;
	create table w_ids_kept as
		select
			count(distinct CustomerID)
		from v_ec_trans
		where CustomerID in (
				select
					CustomerID
				from
					w_ids
			)
			and UnitPrice > 0
			and invoiceDate >= v_cdate
			and invoiceDate < v_date_to
	;
end 
$$ LANGUAGE plpgsql;
	
			
select count(*) from w_ids union all select * from w_ids_kept ;