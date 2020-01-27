workflow SimpleVariantSelection {
  String gatk
  File refFasta
  File refIndex
  File refDict
  String name
  String resDir

  call haplotypeCaller {
    input:
      sampleName = name,
      RefFasta = refFasta,
      GATK = gatk,
      RefIndex = refIndex,
      RefDict = refDict,
      ResDir = resDir
  }
  call select as selectSNPs {
    input:
      sampleName = name,
      RefFasta = refFasta,
      GATK = gatk,
      RefIndex = refIndex,
      RefDict = refDict,
      type="SNP",
      rawVCF=haplotypeCaller.rawVCF,
      ResDir = resDir
    }
  call select as selectIndels {
    input:
      sampleName = name,
      RefFasta = refFasta,
      GATK = gatk,
      RefIndex = refIndex,
      RefDict = refDict,
      type="INDEL",
      rawVCF=haplotypeCaller.rawVCF,
      ResDir = resDir
    }
    call hardFilterSNP {
      input:
        RefFasta = refFasta,
        GATK = gatk,
        sampleName = name,
        RefIndex = refIndex,
        RefDict = refDict,
        rawSNPs = selectSNPs.rawSubset,
        ResDir = resDir
    }
    call hardFilterIndel {
      input:
        RefFasta = refFasta,
        GATK = gatk,
        sampleName = name,
        RefIndex = refIndex,
        RefDict = refDict,
        rawIndels = selectIndels.rawSubset,
        ResDir = resDir
    }
    call combine {
      input:
        RefFasta = refFasta,
        GATK = gatk,
        sampleName = name,
        RefIndex = refIndex,
        RefDict = refDict,
        filteredSNPs = hardFilterSNP.filteredSNPs,
        filteredIndels = hardFilterIndel.filteredIndels,
        ResDir = resDir
    }
}

task haplotypeCaller {
  String GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File inputBAM
  File bamIndex
  String ResDir
  command {
    ${GATK} HaplotypeCaller \
        -R ${RefFasta} \
        -I ${inputBAM} \
        -O ${ResDir}${sampleName}.raw.indels.snps.vcf
  }
  output {
    File rawVCF = "${ResDir}${sampleName}.raw.indels.snps.vcf"
  }
}

task select {
  String GATK
  File RefFasta
  File RefDict
  File RefIndex
  String sampleName
  String type
  String rawVCF
  String ResDir

  command {
    ${GATK} SelectVariants \
    -R ${RefFasta} \
    -V ${rawVCF} \
    --select-type-to-include ${type} \
    -O ${ResDir}${sampleName}_raw.${type}.vcf
  }
  output {
    File rawSubset = "${ResDir}${sampleName}_raw.${type}.vcf"
  }
}

task hardFilterSNP {
  String GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File rawSNPs
  String ResDir

  command {
    ${GATK} VariantFiltration \
      -R ${RefFasta} \
      -V ${rawSNPs} \
      --filter-expression "FS > 60.0" \
      --filter-name "snp_filter" \
      -O ${ResDir}${sampleName}.filtered.snps.vcf
  }
  output {
    File filteredSNPs = "${ResDir}${sampleName}.filtered.snps.vcf"
  }
}

task hardFilterIndel {
  String GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File rawIndels
  String ResDir

  command {
    ${GATK} VariantFiltration \
      -R ${RefFasta} \
      -V ${rawIndels} \
      --filter-expression "FS > 200.0" \
      --filter-name "indel_filter" \
      -O ${ResDir}${sampleName}.filtered.indels.vcf
  }
  output {
    File filteredIndels = "${ResDir}${sampleName}.filtered.indels.vcf"
  }
}

task combine {
  String GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File filteredSNPs
  File filteredIndels
  String ResDir

  command {
    ${GATK} MergeVcfs \
      -R ${RefFasta} \
      -I ${filteredSNPs} \
      -I ${filteredIndels} \
      -O ${ResDir}${sampleName}.filtered.snps.indels.vcf
  }
  output {
    File filteredVCF = "${ResDir}${sampleName}.filtered.snps.indels.vcf"
  }
}
