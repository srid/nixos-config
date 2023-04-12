{ stdenv, fetchurl }:
  let
    mkJenkinsPlugin = { name, src }:
      stdenv.mkDerivation {
        inherit name src;
        phases = "installPhase";
        installPhase = "cp \$src \$out";
        };
  in {
    apache-httpcomponents-client-4-api = mkJenkinsPlugin {
      name = "apache-httpcomponents-client-4-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/apache-httpcomponents-client-4-api/4.5.14-150.v7a_b_9d17134a_5/apache-httpcomponents-client-4-api.hpi";
        sha256 = "ec6919c2ae115234535ed79947e5c3a20e97ebc566d4f0990944f88f84864dc4";
        };
      };
    blueocean-commons = mkJenkinsPlugin {
      name = "blueocean-commons";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-commons/1.27.3/blueocean-commons.hpi";
        sha256 = "d397762452ee2998d2984fe9475c85236a06b8d35d78bdb9bbc382b58258e75b";
        };
      };
    blueocean-core-js = mkJenkinsPlugin {
      name = "blueocean-core-js";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-core-js/1.27.3/blueocean-core-js.hpi";
        sha256 = "7305281db350d6dea7d3c96976c4b204b279164d359a0e4c0a8b6e4ea3410c07";
        };
      };
    blueocean-rest = mkJenkinsPlugin {
      name = "blueocean-rest";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-rest/1.27.3/blueocean-rest.hpi";
        sha256 = "22abb9c3626e5ee059d4782c1d5cb630446961d1c634692a388b4a783e07458c";
        };
      };
    blueocean-web = mkJenkinsPlugin {
      name = "blueocean-web";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-web/1.27.3/blueocean-web.hpi";
        sha256 = "f65be13547d2b5600cd448439a1b06261c7530755de472376f6351120604ed73";
        };
      };
    bootstrap5-api = mkJenkinsPlugin {
      name = "bootstrap5-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/bootstrap5-api/5.2.2-2/bootstrap5-api.hpi";
        sha256 = "3fb41e44141bf4be1d26c50cdf39aca2a8953d36ee6c3e6f6af66cf5778e79d6";
        };
      };
    bouncycastle-api = mkJenkinsPlugin {
      name = "bouncycastle-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/bouncycastle-api/2.27/bouncycastle-api.hpi";
        sha256 = "3837ee8f7402bf4a4dc90f6a228a6086086205bc755e119eadff2b15faf908a3";
        };
      };
    branch-api = mkJenkinsPlugin {
      name = "branch-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/branch-api/2.1071.v1a_188a_562481/branch-api.hpi";
        sha256 = "16f3f3afdb4684e8558eec3c5c7d2523affa78c01b83fa822fb6379aa1470cf8";
        };
      };
    caffeine-api = mkJenkinsPlugin {
      name = "caffeine-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/caffeine-api/2.9.3-65.v6a_47d0f4d1fe/caffeine-api.hpi";
        sha256 = "649fb9a4f730024d30b4890182e9d1c41ff388664fd81786b6cf5ddf9367d89e";
        };
      };
    checks-api = mkJenkinsPlugin {
      name = "checks-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/checks-api/2.0.0/checks-api.hpi";
        sha256 = "a38772be178edd899e1963267541530fc074a8529f88254ad0cf512f7ae89a9b";
        };
      };
    cloudbees-folder = mkJenkinsPlugin {
      name = "cloudbees-folder";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/cloudbees-folder/6.815.v0dd5a_cb_40e0e/cloudbees-folder.hpi";
        sha256 = "cd045bc885fc7b147765fdae56ef3c6ffd98ade2aed7086fd4a691e270b83f04";
        };
      };
    command-launcher = mkJenkinsPlugin {
      name = "command-launcher";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/command-launcher/90.v669d7ccb_7c31/command-launcher.hpi";
        sha256 = "38e6bf4f404d2f8264b338b773a1c930e12143f97c18bd67d6c9661427a6ada8";
        };
      };
    commons-lang3-api = mkJenkinsPlugin {
      name = "commons-lang3-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/commons-lang3-api/3.12.0-36.vd97de6465d5b_/commons-lang3-api.hpi";
        sha256 = "98dfff9f21370d6808392fd811f90a6e173e705970309877596032be1b917ad1";
        };
      };
    commons-text-api = mkJenkinsPlugin {
      name = "commons-text-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/commons-text-api/1.10.0-36.vc008c8fcda_7b_/commons-text-api.hpi";
        sha256 = "250120de1e1e56e246b6180324d99d161a073d4dfbbf8adc2552de92f1bf2ceb";
        };
      };
    conditional-buildstep = mkJenkinsPlugin {
      name = "conditional-buildstep";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/conditional-buildstep/1.4.2/conditional-buildstep.hpi";
        sha256 = "919be166db7b7f90c1445b7dd37981e60880929362908439ba20cb25799fc98f";
        };
      };
    config-file-provider = mkJenkinsPlugin {
      name = "config-file-provider";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/config-file-provider/3.11.1/config-file-provider.hpi";
        sha256 = "c026f18419f3f67521ebcfb3c58797f3f3acf27766919ef3d40691eeedf3761b";
        };
      };
    configuration-as-code = mkJenkinsPlugin {
      name = "configuration-as-code";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/configuration-as-code/1625.v27444588cc3d/configuration-as-code.hpi";
        sha256 = "413a8a73982f2e87dc3a55110ab8d8f292f4b6b5508de21f4fbae6c7005f2ecf";
        };
      };
    credentials = mkJenkinsPlugin {
      name = "credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials/1224.vc23ca_a_9a_2cb_0/credentials.hpi";
        sha256 = "23674ca9c570e36597166d9b5a629383546548594ad9f7f7ffe13594231d16bb";
        };
      };
    credentials-binding = mkJenkinsPlugin {
      name = "credentials-binding";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials-binding/523.vd859a_4b_122e6/credentials-binding.hpi";
        sha256 = "0a9e850728268d2750fe941ef63e35ca0eb42dfa3f425056cbd630a90d9d089a";
        };
      };
    display-url-api = mkJenkinsPlugin {
      name = "display-url-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/display-url-api/2.3.7/display-url-api.hpi";
        sha256 = "1d35d2e9727821c63609a672e872a68172696e8aa81ec6ea07816086f95c684d";
        };
      };
    durable-task = mkJenkinsPlugin {
      name = "durable-task";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/durable-task/504.vb10d1ae5ba2f/durable-task.hpi";
        sha256 = "0c79fdd0a04852987c8457953f89d5089fffb20d78331fabd58647b966268340";
        };
      };
    echarts-api = mkJenkinsPlugin {
      name = "echarts-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/echarts-api/5.4.0-3/echarts-api.hpi";
        sha256 = "61d44c082bdccf9e2ea27feffa3d41c2988cdfa76d84a7dbf21e0e6c9445de24";
        };
      };
    font-awesome-api = mkJenkinsPlugin {
      name = "font-awesome-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/font-awesome-api/6.3.0-2/font-awesome-api.hpi";
        sha256 = "e5bcec111b9612fd268786d208a06ffe6d755469cf5890593d2975337bf318db";
        };
      };
    git = mkJenkinsPlugin {
      name = "git";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/git/5.0.0/git.hpi";
        sha256 = "5ad8e2f6ef7b9bec00c889092fc702ef21c1d4a334a5c9c8f00cffa65cf63605";
        };
      };
    git-client = mkJenkinsPlugin {
      name = "git-client";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/git-client/4.2.0/git-client.hpi";
        sha256 = "42c84f73e80fe47041d6ecd66b3f98d4f239fd460b7b727d14a78174bc8ae40e";
        };
      };
    github = mkJenkinsPlugin {
      name = "github";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github/1.37.0/github.hpi";
        sha256 = "9314887062bc880504dab25a3958844fe613cb9268d77f00906d11fe8c669d6d";
        };
      };
    github-api = mkJenkinsPlugin {
      name = "github-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github-api/1.303-417.ve35d9dd78549/github-api.hpi";
        sha256 = "3d241357ff65631c97b0abb130fe72c421b842923cd09efdfb363f12e910b17e";
        };
      };
    github-branch-source = mkJenkinsPlugin {
      name = "github-branch-source";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github-branch-source/1703.vd5a_2b_29c6cdc/github-branch-source.hpi";
        sha256 = "0600887314957ba66181aac02d16d40cd0e46cb49a4418a729da726b97ec70c7";
        };
      };
    instance-identity = mkJenkinsPlugin {
      name = "instance-identity";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/instance-identity/142.v04572ca_5b_265/instance-identity.hpi";
        sha256 = "0545ef7fa6b5240f2baf1a385464e5d4f2ab43ac5784460c82d4eb1e5f2dbd6f";
        };
      };
    ionicons-api = mkJenkinsPlugin {
      name = "ionicons-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ionicons-api/45.vf54fca_5d2154/ionicons-api.hpi";
        sha256 = "56b1e6377326e36f8d98e7e992aa2a6622e9e556efc78b2408a5418eedf6074b";
        };
      };
    jackson2-api = mkJenkinsPlugin {
      name = "jackson2-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jackson2-api/2.14.2-319.v37853346a_229/jackson2-api.hpi";
        sha256 = "a8e9fce51913f55ec42924cb92447c807eb9d8560f8fa6648a5231d31118f896";
        };
      };
    jakarta-activation-api = mkJenkinsPlugin {
      name = "jakarta-activation-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jakarta-activation-api/2.0.1-3/jakarta-activation-api.hpi";
        sha256 = "fa99c0288dcd24e7bbc857974d07a622d19d48ba71a39564b6c1fa9a14773ed1";
        };
      };
    jakarta-mail-api = mkJenkinsPlugin {
      name = "jakarta-mail-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jakarta-mail-api/2.0.1-3/jakarta-mail-api.hpi";
        sha256 = "af8d0ed38eed3231a078291c4c5f1f0c342970a860a88cdd11ff3ebb606bd3b7";
        };
      };
    javadoc = mkJenkinsPlugin {
      name = "javadoc";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/javadoc/226.v71211feb_e7e9/javadoc.hpi";
        sha256 = "a2913b6b99f0d204400ddfcbf6ef50edaa0e869a4f0fde2c38f13432943a762d";
        };
      };
    javax-activation-api = mkJenkinsPlugin {
      name = "javax-activation-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/javax-activation-api/1.2.0-6/javax-activation-api.hpi";
        sha256 = "8af800837a3bddca75d7f962fbcf535d1c3c214f323fa57c141cecdde61516a9";
        };
      };
    jaxb = mkJenkinsPlugin {
      name = "jaxb";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jaxb/2.3.8-1/jaxb.hpi";
        sha256 = "607213a0b4d959f9982ef53e908c8cfc37f2334e38bb49487f7f8eed6b6c4956";
        };
      };
    jenkins-design-language = mkJenkinsPlugin {
      name = "jenkins-design-language";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jenkins-design-language/1.27.3/jenkins-design-language.hpi";
        sha256 = "e67a942df722a6732d8b5aa3297924acf302aef954a9e306a80b8ccd10c6ae58";
        };
      };
    jjwt-api = mkJenkinsPlugin {
      name = "jjwt-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jjwt-api/0.11.5-77.v646c772fddb_0/jjwt-api.hpi";
        sha256 = "cc10fc60c47fe60a585224dad45dde166dd0268cf6efc9967fbf870e3601ceb2";
        };
      };
    job-dsl = mkJenkinsPlugin {
      name = "job-dsl";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/job-dsl/1.83/job-dsl.hpi";
        sha256 = "662db3bddecfa5b9de71a55647da5da8c9c753cdbc5d0d53023412162016d3a7";
        };
      };
    jquery3-api = mkJenkinsPlugin {
      name = "jquery3-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jquery3-api/3.6.4-1/jquery3-api.hpi";
        sha256 = "3228b5e3944e004d09a73c2b2b6548851ac725c1e955fb09c8ca577f83a490f8";
        };
      };
    jsch = mkJenkinsPlugin {
      name = "jsch";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jsch/0.1.55.61.va_e9ee26616e7/jsch.hpi";
        sha256 = "8379691a06b084540ce6b70c11fc055720098d262b717cf46429a2afd6ca8ee6";
        };
      };
    junit = mkJenkinsPlugin {
      name = "junit";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/junit/1189.v1b_e593637fa_e/junit.hpi";
        sha256 = "4df91b00e439844382c4b58fb27a1530591a882a02f7a2645e0f63b29c5e46d2";
        };
      };
    mailer = mkJenkinsPlugin {
      name = "mailer";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mailer/448.v5b_97805e3767/mailer.hpi";
        sha256 = "0b5f9925bb002b286e2ea46fa8157b3b957845c8d9cedf57cb00ede6bfe46609";
        };
      };
    managed-scripts = mkJenkinsPlugin {
      name = "managed-scripts";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/managed-scripts/1.5.6/managed-scripts.hpi";
        sha256 = "72ae9dcd4085bdfbe810c1e04e30269520db6a1cefba339e34c13f39fa8384b8";
        };
      };
    mapdb-api = mkJenkinsPlugin {
      name = "mapdb-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mapdb-api/1.0.9-28.vf251ce40855d/mapdb-api.hpi";
        sha256 = "b924749b6445270cd2ed881f81925fedd71f67a2993473b9172e1e7a9a4023be";
        };
      };
    matrix-project = mkJenkinsPlugin {
      name = "matrix-project";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/matrix-project/785.v06b_7f47b_c631/matrix-project.hpi";
        sha256 = "e42f01c243f2a5797649438cbf523b7a76b40d1ff3cf9075898fe1e824f2e525";
        };
      };
    maven-plugin = mkJenkinsPlugin {
      name = "maven-plugin";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/maven-plugin/3.21/maven-plugin.hpi";
        sha256 = "86e4a8ede78fcd5bea375685ba29713f5e08ee07467a3c6bc768d5aa3ff51e01";
        };
      };
    metrics = mkJenkinsPlugin {
      name = "metrics";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/metrics/4.2.13-420.vea_2f17932dd6/metrics.hpi";
        sha256 = "ccdd21e7890530e555285cfd4efe4ea2e33215b99ad1901afdb867fffb554e57";
        };
      };
    mina-sshd-api-common = mkJenkinsPlugin {
      name = "mina-sshd-api-common";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mina-sshd-api-common/2.9.2-62.v199162f0a_2f8/mina-sshd-api-common.hpi";
        sha256 = "e17fd867a7fde524920c9c6abfd6dcba787663e2f8ae395568ee32601cab750f";
        };
      };
    mina-sshd-api-core = mkJenkinsPlugin {
      name = "mina-sshd-api-core";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mina-sshd-api-core/2.9.2-62.v199162f0a_2f8/mina-sshd-api-core.hpi";
        sha256 = "3b9c97702654188cfa9f1347eae49c7ef88d965fd07daf41da4947c618868457";
        };
      };
    node-iterator-api = mkJenkinsPlugin {
      name = "node-iterator-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/node-iterator-api/49.v58a_8b_35f8363/node-iterator-api.hpi";
        sha256 = "106b4ba84478412d2f7bb30fa7e4aad13c5235b235cfbbf62f072904342969ea";
        };
      };
    okhttp-api = mkJenkinsPlugin {
      name = "okhttp-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/okhttp-api/4.10.0-132.v7a_7b_91cef39c/okhttp-api.hpi";
        sha256 = "d64fcc0e29c76c5b0197f8585267f53ffa96e0ea0709c7aa4a4ecd0eccfeb6ca";
        };
      };
    parameterized-trigger = mkJenkinsPlugin {
      name = "parameterized-trigger";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.45/parameterized-trigger.hpi";
        sha256 = "58d1441fb5cfb4837c67d4d87a8925f45d8e99a1472a8f8010fbecc0b6ecfed9";
        };
      };
    pipeline-build-step = mkJenkinsPlugin {
      name = "pipeline-build-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-build-step/488.v8993df156e8d/pipeline-build-step.hpi";
        sha256 = "e546e1443229a93cd9adcf05033f499b12cda0b29156974fb5e5e98a5f57e795";
        };
      };
    pipeline-graph-analysis = mkJenkinsPlugin {
      name = "pipeline-graph-analysis";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-graph-analysis/202.va_d268e64deb_3/pipeline-graph-analysis.hpi";
        sha256 = "3ea34acec187c036d5e688192dcd75e70fc1c6b1018969c1c04ae7f1e6bb3410";
        };
      };
    pipeline-graph-view = mkJenkinsPlugin {
      name = "pipeline-graph-view";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-graph-view/183.v9e27732d970f/pipeline-graph-view.hpi";
        sha256 = "b59c385a5ae48db674e6d060f85da453b1141e98f8ca81b017bdd8ca6f1cf67f";
        };
      };
    pipeline-groovy-lib = mkJenkinsPlugin {
      name = "pipeline-groovy-lib";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-groovy-lib/656.va_a_ceeb_6ffb_f7/pipeline-groovy-lib.hpi";
        sha256 = "80648aa71176b01695886288a89c56487ad9195ea678a4cdd033c69b7147e026";
        };
      };
    pipeline-input-step = mkJenkinsPlugin {
      name = "pipeline-input-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-input-step/466.v6d0a_5df34f81/pipeline-input-step.hpi";
        sha256 = "81fbb12caffea58e298d0662a2fff4cc2ad087b92718d917f5c00b63909a8fe0";
        };
      };
    pipeline-milestone-step = mkJenkinsPlugin {
      name = "pipeline-milestone-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-milestone-step/111.v449306f708b_7/pipeline-milestone-step.hpi";
        sha256 = "48bea7547ad989b0c1abb550c3e2ff27bb48d7ff7685e84c0f39d5148bf6fd6b";
        };
      };
    pipeline-model-api = mkJenkinsPlugin {
      name = "pipeline-model-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-api/2.2125.vddb_a_44a_d605e/pipeline-model-api.hpi";
        sha256 = "b49344c29306471197f3559eb1d87cb7a85b6cb6129f0428f1441d867adcf2bf";
        };
      };
    pipeline-model-definition = mkJenkinsPlugin {
      name = "pipeline-model-definition";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-definition/2.2125.vddb_a_44a_d605e/pipeline-model-definition.hpi";
        sha256 = "62f90a54af0821a724ecba00559ea62978de7ff66d24ee7fba67866c64598aa3";
        };
      };
    pipeline-model-extensions = mkJenkinsPlugin {
      name = "pipeline-model-extensions";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-extensions/2.2125.vddb_a_44a_d605e/pipeline-model-extensions.hpi";
        sha256 = "67b3517f347daa9612a2625ff3381bfda2e7b40b9babaab084161aa60d512be6";
        };
      };
    pipeline-stage-step = mkJenkinsPlugin {
      name = "pipeline-stage-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-stage-step/305.ve96d0205c1c6/pipeline-stage-step.hpi";
        sha256 = "8d5112dd70d9912f33bdb64858bbfa718372ab79447fa91f1e07fdb41c05bb7e";
        };
      };
    pipeline-stage-tags-metadata = mkJenkinsPlugin {
      name = "pipeline-stage-tags-metadata";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-stage-tags-metadata/2.2125.vddb_a_44a_d605e/pipeline-stage-tags-metadata.hpi";
        sha256 = "fd2b092b8472f24bbbba3b95477782fd1aece3e6e64382461b94da1821d04350";
        };
      };
    pipeline-utility-steps = mkJenkinsPlugin {
      name = "pipeline-utility-steps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-utility-steps/2.15.1/pipeline-utility-steps.hpi";
        sha256 = "cf415612a7fe9f6f3155a50b751ebf71bfa1a72c0a7b889105bb4c2df059c260";
        };
      };
    plain-credentials = mkJenkinsPlugin {
      name = "plain-credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/plain-credentials/143.v1b_df8b_d3b_e48/plain-credentials.hpi";
        sha256 = "23a74199dcb19659e19c9d92e4797b40bc9feb48400ce56ae43fa4d9520df901";
        };
      };
    plugin-util-api = mkJenkinsPlugin {
      name = "plugin-util-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/plugin-util-api/3.2.0/plugin-util-api.hpi";
        sha256 = "e32105a9c8017643a007cc4565a0ee8bff3a556bf93ec7ac0788c5116704e77f";
        };
      };
    project-inheritance = mkJenkinsPlugin {
      name = "project-inheritance";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/project-inheritance/21.04.03/project-inheritance.hpi";
        sha256 = "c7e714d2a096ceb719f9a91eb61d12c6da1619f139254ce91db1ead58520ecf7";
        };
      };
    promoted-builds = mkJenkinsPlugin {
      name = "promoted-builds";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/promoted-builds/892.vd6219fc0a_efb/promoted-builds.hpi";
        sha256 = "1f0483c03cfd227a8d8e1924a08aeb43f23a2414dd7602ba4c4871e3a6447ea6";
        };
      };
    rebuild = mkJenkinsPlugin {
      name = "rebuild";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/rebuild/1.34/rebuild.hpi";
        sha256 = "84e3ac4876488adb8649172ace2132a6fd887faf0809235154e40d330d912a74";
        };
      };
    run-condition = mkJenkinsPlugin {
      name = "run-condition";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/run-condition/1.5/run-condition.hpi";
        sha256 = "7ed94d7196676c00e45b5bf7e191831eee0e49770dced1c266b8055980b339ca";
        };
      };
    scm-api = mkJenkinsPlugin {
      name = "scm-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/scm-api/631.v9143df5b_e4a_a/scm-api.hpi";
        sha256 = "981a908f2b2af2fd7947d2c2dc58bb0e85185ba3a0a741f1f948cd904d3bdb30";
        };
      };
    script-security = mkJenkinsPlugin {
      name = "script-security";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/script-security/1229.v4880b_b_e905a_6/script-security.hpi";
        sha256 = "c2a36c560e04a099a4037a08298a8b87bb514ae739b915fd882ba07b2fbf25e6";
        };
      };
    snakeyaml-api = mkJenkinsPlugin {
      name = "snakeyaml-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/snakeyaml-api/1.33-95.va_b_a_e3e47b_fa_4/snakeyaml-api.hpi";
        sha256 = "c6cc0607f773e3b026ab2c121856b905f97415c9b1fb20e884cd6297e8d0bf21";
        };
      };
    ssh-credentials = mkJenkinsPlugin {
      name = "ssh-credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ssh-credentials/305.v8f4381501156/ssh-credentials.hpi";
        sha256 = "008ffb999ce9c7949c1299e1305007178bd0bedfd4c8401d6a4e92eeba635ff4";
        };
      };
    ssh-slaves = mkJenkinsPlugin {
      name = "ssh-slaves";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ssh-slaves/2.877.v365f5eb_a_b_eec/ssh-slaves.hpi";
        sha256 = "64dd557487fbab57c35d78e241e07f6596a46fb43723031a4c1c3d783e50d016";
        };
      };
    structs = mkJenkinsPlugin {
      name = "structs";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/structs/324.va_f5d6774f3a_d/structs.hpi";
        sha256 = "65dd0a68c663b08e30ed254f37549e9ccfab18d27e4f1182cc7eed6d4d02c958";
        };
      };
    subversion = mkJenkinsPlugin {
      name = "subversion";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/subversion/2.17.1/subversion.hpi";
        sha256 = "8647902fe5786df248cb9a2c77322210871270a6c233de7426cbc2706738be3c";
        };
      };
    support-core = mkJenkinsPlugin {
      name = "support-core";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/support-core/1266.v6d096c154c90/support-core.hpi";
        sha256 = "31d3e23cd5ecc08c13aa8584ae69ee7bede124199a503983db5ed9ed607906df";
        };
      };
    theme-manager = mkJenkinsPlugin {
      name = "theme-manager";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/theme-manager/1.6/theme-manager.hpi";
        sha256 = "1ea4f6b571befade0611ddb104cd49b94ecd41a427deadfcf3cb504903222d63";
        };
      };
    token-macro = mkJenkinsPlugin {
      name = "token-macro";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/token-macro/321.vd7cc1f2a_52c8/token-macro.hpi";
        sha256 = "095084f680c37f7d18d6468e2c4aecd74430f324c1d6ebb23d8551d34debdadb";
        };
      };
    trilead-api = mkJenkinsPlugin {
      name = "trilead-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/trilead-api/2.84.v72119de229b_7/trilead-api.hpi";
        sha256 = "72ee883ee83a94a0a84e9821123ae3f1eb09e7650896c5e0a78be8d0df50bde8";
        };
      };
    variant = mkJenkinsPlugin {
      name = "variant";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/variant/59.vf075fe829ccb/variant.hpi";
        sha256 = "14ac8250e7ff958e45d8e47c05d5cb495602a34737a7a2680e9e364798624fb3";
        };
      };
    vsphere-cloud = mkJenkinsPlugin {
      name = "vsphere-cloud";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/vsphere-cloud/2.27/vsphere-cloud.hpi";
        sha256 = "b584e8c515cdf41fa47740087677e11af80c402ef6c4fb5f153b9d8e05ccbdea";
        };
      };
    workflow-aggregator = mkJenkinsPlugin {
      name = "workflow-aggregator";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-aggregator/596.v8c21c963d92d/workflow-aggregator.hpi";
        sha256 = "45933e33058d48c6f3e70a37f31ecb65e48939ce91d46bc98b60f5595316c1d1";
        };
      };
    workflow-api = mkJenkinsPlugin {
      name = "workflow-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-api/1208.v0cc7c6e0da_9e/workflow-api.hpi";
        sha256 = "b99225d0926f1956a516ad30e8fb4c0f904c92f835be7c91a9d6a17fa8c78d88";
        };
      };
    workflow-basic-steps = mkJenkinsPlugin {
      name = "workflow-basic-steps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-basic-steps/1010.vf7a_b_98e847c1/workflow-basic-steps.hpi";
        sha256 = "2106fde9cc20fb037f2f9b33b0684fb7817b4f40d4e73f0ed2e20bcaa3fd9159";
        };
      };
    workflow-cps = mkJenkinsPlugin {
      name = "workflow-cps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-cps/3653.v07ea_433c90b_4/workflow-cps.hpi";
        sha256 = "7e9d151fd51747f2727274044113dd939255e136eb2c3f3d26d9243ebe153f64";
        };
      };
    workflow-durable-task-step = mkJenkinsPlugin {
      name = "workflow-durable-task-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-durable-task-step/1241.v1a_63e465f943/workflow-durable-task-step.hpi";
        sha256 = "e59161dc69c6189ffb6dd2c5a0e8603a7b1861d7a7b09ed1c2b5e025a9fa73d5";
        };
      };
    workflow-job = mkJenkinsPlugin {
      name = "workflow-job";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-job/1289.vd1c337fd5354/workflow-job.hpi";
        sha256 = "5bd44193b84159d118ee8aa0fd163d8d4a7aa062f113f9043a2a5c0e9938c617";
        };
      };
    workflow-multibranch = mkJenkinsPlugin {
      name = "workflow-multibranch";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-multibranch/733.v109046189126/workflow-multibranch.hpi";
        sha256 = "539e0d6a50f840af044ee4976b2e027b6ac4947d45a371c32a2352259f28a2d9";
        };
      };
    workflow-scm-step = mkJenkinsPlugin {
      name = "workflow-scm-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-scm-step/408.v7d5b_135a_b_d49/workflow-scm-step.hpi";
        sha256 = "f6f8892c954ca3e3a8eafcc86812b1ca3d226dd30793b19fc91f75e6557518b7";
        };
      };
    workflow-step-api = mkJenkinsPlugin {
      name = "workflow-step-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-step-api/639.v6eca_cd8c04a_a_/workflow-step-api.hpi";
        sha256 = "e297994ef4892b292fed850431cafe5a687fe64fbb9ddf9b7938d2b74db81763";
        };
      };
    workflow-support = mkJenkinsPlugin {
      name = "workflow-support";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-support/839.v35e2736cfd5c/workflow-support.hpi";
        sha256 = "3fe54cab155ad9bac49d3a98df1377f5795f8acf556f829ac48b32f5567c02bd";
        };
      };
    }