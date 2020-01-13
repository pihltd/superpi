task runSamViewHeader {
  String container
  String datamount
  String resultsmount
  String bamfile
  String samtoolsoutput
  command {
    docker run \
    -i \
    --rm \
    -v ${datamount} \
    -v ${resultsmount} \
     ${container} \
    /bin/bash -c "samtools view -H ${bamfile} > ${samtoolsoutput}"
  }
  output {
   Array[String] response = read_lines(stdout())
  }
}

workflow analysis{
  call runSamViewHeader
}
