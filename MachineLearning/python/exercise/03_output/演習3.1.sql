select
	count(*) as ids,
	sum(purchase_amount) as purchase_amount,
	sum(trips) as trips
from 
(
	select 
		CustomerID,
		sum(Quantity*UnitPrice) as purchase_amount,
		count(distinct InvoiceNo) as trips
	from v_ec_trans
	where
		invoicedate between cast ('2011-01-01' as date) and cast ('2011-07-01' as date)
		and CustomerID is not null
		and UnitPrice > 0
	group by 
		CustomerID
	having 
		count(distinct invoiceNo) >=4

) t
	