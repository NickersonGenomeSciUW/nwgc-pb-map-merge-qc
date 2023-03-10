process MAP_HIFI_BAMS {

    label "MAP_HIFI_BAMS_${params.sampleId}_${params.userId}"

    debug true
    module "$params.initModules"
    module "$params.smrttoolsModule"
    memory "$params.mapHiFiBams_memory"
    clusterOptions "$params.defaultClusterOptions -pe serial $params.mapHiFiBams_numCPUs -l d_rt=1:0:0"

    input:
        path hiFiBam

    output:
        path "*.mapped.bam",  emit: mapped_bam
        path "versions.yaml", emit: versions

    script:
        """
        pbmm2 \\
            align \\
            --num-threads $params.mapHiFiBams_numCPUs \\
            --unmapped \\
            $params.referenceGenome \\
            $hiFiBam \\
            ${hiFiBam}.mapped.bam

        cat <<-END_VERSIONS > versions.yaml
        '${task.process}_${task.index}':
            pbmm2: \$(pbmm2 --version | awk '{print \$2}')
        END_VERSIONS
        """

}
