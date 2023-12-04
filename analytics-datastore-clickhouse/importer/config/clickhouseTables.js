const CLUSTERED_MODE = process.env.CLUSTERED_MODE || "true";

const queries =
  Boolean(CLUSTERED_MODE) === true
    ? [
        `CREATE TABLE patient_example(
					id String,
					version String NULL,
					inserted_at DateTime DEFAULT now(),
					last_updated Date NULL,
					goldenId String,
					patientGivenName String,
					patientFamilyName String,
				) 
				ENGINE=MergeTree
				ORDER BY tuple();`,
        `CREATE TABLE observation_example(
					id String,
					version String NULL,
					inserted_at DateTime DEFAULT now(),
					last_updated Date NULL,
					observationValue Double,
					patientId String,
				) 
				ENGINE=MergeTree
				ORDER BY tuple();`,
      ]
    : [
        `CREATE TABLE patient_example ON CLUSTER '{cluster}' (
					id String,
					version String NULL,
					inserted_at DateTime DEFAULT now(),
					last_updated Date NULL,
					goldenId String,
					patientGivenName String,
					patientFamilyName String,
				) 
				ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
				ORDER BY tuple();`,
        `CREATE TABLE observation_example ON CLUSTER '{cluster}' (
					id String,
					version String NULL,
					inserted_at DateTime DEFAULT now(),
					last_updated Date NULL,
					observationValue Double,
					patientId String,
				) 
				ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/{table}', '{replica}')
				ORDER BY tuple();`,
      ];

module.exports = queries;
