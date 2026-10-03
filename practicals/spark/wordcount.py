from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("wordcount").getOrCreate()
lines = spark.sparkContext.textFile("/lab/wordcount/input/input.txt")
counts = (lines.flatMap(lambda l: l.split())
               .map(lambda w: (w, 1))
               .reduceByKey(lambda a, b: a + b))
for word, n in counts.take(20):
    print(word, n)
spark.stop()
