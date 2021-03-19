--検証用データ作成
do $$
	declare 
		v_cdate date = cast('2011-10-01' as date);
		v_date_from date = v_cdate - INTERVAL '6 Month'; 
		v_date_to date = v_cdate + INTERVAL '3 Month'; 
		minInvoice int = 4; --#{4:優良, 1:全体}
		
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
	
	--正解ラベル(顧客別のTGT)
	drop table if exists w_labels;
	create table w_labels as
		select
    		a.CustomerID,
    		case when b.CustomerID is null 
			then 1 else 0 
			end as TGT
		from w_ids a
		left outer join
		(
			select distinct CustomerID
			from v_ec_trans
			where CustomerID is not null 
				and UnitPrice > 0 
				and InvoiceDate >= v_cdate 
				and InvoiceDate < v_date_to
		) b on a.CustomerID = b.CustomerID
	;	
	--# 特徴量抽出(TGT以外)
	drop table if exists w_features;
	create table w_features as
		select
			CustomerID,
			count(distinct InvoiceNo)                               as trips,
			sum(quantity * unitprice)                               as amount_of_yen,
			sum(quantity)                                           as quantity,
			date_part('day',max(InvoiceDate) - min(InvoiceDate))	as purchase_period,
			date_part('day',v_cdate - max(InvoiceDate))             as purchase_recency,
			sum(quantity * unitprice) / count(distinct InvoiceNo)   as purchase_amount_per_trips,
			1.0*date_part('day', max(InvoiceDate) - min(InvoiceDate)) / count(distinct InvoiceNo) as regularity,
			count(distinct case when StockCode2 like 'C%' then InvoiceNo else null end)    as trips_cancellation,
			count(distinct case when StockCode2='85099' then InvoiceNo else null end)    as trips_cat85099,
			count(distinct case when StockCode2='85123' then InvoiceNo else null end)    as trips_cat85123,
			count(distinct case when StockCode2='22423' then InvoiceNo else null end)    as trips_cat22423,
			count(distinct case when StockCode2='47566' then InvoiceNo else null end)    as trips_cat47566,
			count(distinct case when StockCode2='84879' then InvoiceNo else null end)    as trips_cat84879,
			--#最頻値を取得
			mode() within group (order by StockCode2 desc) as mode_category
		from
			v_ec_trans
		where
			CustomerID is not null
		and UnitPrice > 0
		and InvoiceDate >= v_date_from
		and InvoiceDate < v_cdate
		group by
			CustomerID
	;
	
	
	drop table if exists dm_for_fwd;
	create table dm_for_fwd as
		-- drop table if exists dm_for_fwd;  -- フォワード検証用の場合はこちらに置き換えよ
		-- create table dm_for_fwd as        -- 同上
		select 
			b.*, 
			a.TGT
		from w_labels a
		left outer join w_features b on a.CustomerID = b.CustomerID
		;
end 
$$ LANGUAGE plpgsql;

--to CSV for Model
copy dm_for_fwd to 'C:\Users\Public\dm_for_fwd.csv' WITH CSV HEADER DELIMITER ',';
	