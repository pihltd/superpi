workflow mapScatter {
  Map [String, String] Fastqs
  String Sample
  String Picard
  String Picardtool

  scatter (pair in Fastqs){
    String fastq1 = pair.left
    String fastq2 = pair.right

    call bamIt {
      input:
        Fastq1 = fastq1,
        Fastq2 = fastq2,
        samplename = Sample,
        picard = Picard,
        picardtool = Picardtool
    }
  }
}


task bamIt {
  String Fastq1
  String Fastq2
  String samplename
  String picard
  String picardtool

  command {
    java -jar ${picard} ${picardtool} \
      FASTQ=${Fastq1} \
      FASTQ2=${Fastq2} \
      OUTPUT=${samplename}.unmapped.bam
  }

  output {
    File bamfile = "${samplename}.unmapped.bam"
  }
}
