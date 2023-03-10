process PICARD_COVERAGE_METRICS {

    label "PICARD_COVERAGE_METRICS_${params.sampleId}_${params.userId}"

    publishDir "$params.sampleQCDirectory", mode: 'link', pattern: '*.picard.coverage.txt'
 
    debug true
    module "$params.initModules"
    module "$params.picardModule"
    memory "$params.picardCoverageMetrics_memory"
    clusterOptions "$params.defaultClusterOptions -l d_rt=1:0:0"

    input:
        path bam

    output:
        path "*.picard.coverage.txt"
        path "versions.yaml", emit: versions

    script:
        """
        mkdir -p $params.sampleQCDirectory

        java \
            -jar \$PICARD_DIR/picard.jar CollectWgsMetrics \
            --INPUT $bam \
            --COUNT_UNPAIRED true \
            --READ_LENGTH 17000 \
            --INCLUDE_BQ_HISTOGRAM \
            --REFERENCE_SEQUENCE $params.referenceGenome \
            --VALIDATION_STRINGENCY LENIENT \
            --OUTPUT ${params.sampleId}.picard.coverage.txt

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}':
            java: \$(java -version 2>&1 | grep version | awk '{print \$3}' | tr -d '"''')
            picard: \$(java -jar \$PICARD_DIR/picard.jar CollectRawWgsMetrics --version 2>&1 | awk '{split(\$0,a,":"); print a[2]}')
        END_VERSIONS

        """

}
