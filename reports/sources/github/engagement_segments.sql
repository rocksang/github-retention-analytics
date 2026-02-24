select engagement_segment, count(*) as users
from mart_engagement_segments
group by engagement_segment
order by users desc
