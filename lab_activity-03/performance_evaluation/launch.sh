i=1
while test $i -le 1000
do
  echo $i
  argos3 -c test-subs-evaluation.argos | tail -n 2 | grep f_distance | cut -f2 -d' ' >> results.txt
  i=`expr $i + 1`
done