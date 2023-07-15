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
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-commons/1.27.4/blueocean-commons.hpi";
        sha256 = "fa81db0588939f59a5270cf6fc0e04ed397dcfd2b425415890f8092a863dd56f";
        };
      };
    blueocean-core-js = mkJenkinsPlugin {
      name = "blueocean-core-js";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-core-js/1.27.4/blueocean-core-js.hpi";
        sha256 = "b62c32591998d46c9ade82a8b84a6259d7e5e3f468d68d3c66db63c98c0e0b9e";
        };
      };
    blueocean-rest = mkJenkinsPlugin {
      name = "blueocean-rest";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-rest/1.27.4/blueocean-rest.hpi";
        sha256 = "08405d42d25b420fcfaed110f5f6db32ee45a7846d81518109c2a97fca8e6d93";
        };
      };
    blueocean-web = mkJenkinsPlugin {
      name = "blueocean-web";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-web/1.27.4/blueocean-web.hpi";
        sha256 = "32dd9563ec3fa5837a574427bf5c53ec99d61abb6e57bd2539e824f52a8ca321";
        };
      };
    bootstrap5-api = mkJenkinsPlugin {
      name = "bootstrap5-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/bootstrap5-api/5.3.0-1/bootstrap5-api.hpi";
        sha256 = "76d3ade537956d8a22ff7378df49ac38aa7baa6f50a6fc7ea6233426de48937b";
        };
      };
    bouncycastle-api = mkJenkinsPlugin {
      name = "bouncycastle-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/bouncycastle-api/2.29/bouncycastle-api.hpi";
        sha256 = "b4579237ea34c5d45d02c8cb16ca35794163ca114d87dfb75e84949798a18ee6";
        };
      };
    branch-api = mkJenkinsPlugin {
      name = "branch-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/branch-api/2.1122.v09cb_8ea_8a_724/branch-api.hpi";
        sha256 = "cdde6fda3be6e1f46bf1deffcd269a29ed9005cece453b571f59653809053148";
        };
      };
    caffeine-api = mkJenkinsPlugin {
      name = "caffeine-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/caffeine-api/3.1.6-115.vb_8b_b_328e59d8/caffeine-api.hpi";
        sha256 = "4835f1b954abefd8599eba6e39801016d28d8cbde03cfc13f8feb8cc537fac28";
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
        url = "https://updates.jenkins-ci.org/download/plugins/command-launcher/100.v2f6722292ee8/command-launcher.hpi";
        sha256 = "638176ea92e5fe6bc1d7a99af0cd1513f16dc1e9b17c6684732c8ee07bb10e4a";
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
        url = "https://updates.jenkins-ci.org/download/plugins/config-file-provider/951.v0461b_87b_721b_/config-file-provider.hpi";
        sha256 = "eb86b69c444169d5cdab1a460d524636cb65bd42690cc47037399342d02502ee";
        };
      };
    configuration-as-code = mkJenkinsPlugin {
      name = "configuration-as-code";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/configuration-as-code/1647.ve39ca_b_829b_42/configuration-as-code.hpi";
        sha256 = "e112f8a174208477298ca430d4f21dcd0c2027faa47a5315c83661c742dd1962";
        };
      };
    credentials = mkJenkinsPlugin {
      name = "credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials/1254.vb_96f366e7b_a_d/credentials.hpi";
        sha256 = "f1a7647fb17e1ab522883c1ccfb7e0cc5af181d23df3167aac92d5eb4e50beb9";
        };
      };
    credentials-binding = mkJenkinsPlugin {
      name = "credentials-binding";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials-binding/604.vb_64480b_c56ca_/credentials-binding.hpi";
        sha256 = "6a914bef0b5a0cea8ece8ce66b163718a58007b7082adc3798c2960c7a025acc";
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
        url = "https://updates.jenkins-ci.org/download/plugins/durable-task/510.v324450f8dca_4/durable-task.hpi";
        sha256 = "bf615a6f59f4d6d9f1ba1030905b89e951f2958d48e0569c21fa41519a9d776b";
        };
      };
    echarts-api = mkJenkinsPlugin {
      name = "echarts-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/echarts-api/5.4.0-5/echarts-api.hpi";
        sha256 = "59041765aaba882f00c15cdeb9edfff457a11ec1137b9b6bfc9212c2b99dde9b";
        };
      };
    font-awesome-api = mkJenkinsPlugin {
      name = "font-awesome-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/font-awesome-api/6.4.0-1/font-awesome-api.hpi";
        sha256 = "3a0099d56f80315e2fc3d5438bc3addbdf181af94cabc9a28bc34f11b9235e28";
        };
      };
    git = mkJenkinsPlugin {
      name = "git";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/git/5.2.0/git.hpi";
        sha256 = "86895fb0350a0fc7904fdad661d5c36fa7d2f7783e151fe44b83f48b4e75dc7e";
        };
      };
    git-client = mkJenkinsPlugin {
      name = "git-client";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/git-client/4.4.0/git-client.hpi";
        sha256 = "4b00c18ae7856ebda8fd7bb0bf18dc4d1eb0a27f7f54f97dfce5000a9c8d8b04";
        };
      };
    github = mkJenkinsPlugin {
      name = "github";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github/1.37.1/github.hpi";
        sha256 = "b42715ac53f27670e26b3e47f98bbde52c098a254bfcad4978273629b12603f0";
        };
      };
    github-api = mkJenkinsPlugin {
      name = "github-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github-api/1.314-431.v78d72a_3fe4c3/github-api.hpi";
        sha256 = "d961e384cc796cb2402aaca266cffa45d3f23f449f5771d30d72c5eca630c8f7";
        };
      };
    github-branch-source = mkJenkinsPlugin {
      name = "github-branch-source";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github-branch-source/1728.v859147241f49/github-branch-source.hpi";
        sha256 = "894ddecaf6392787b50f65fb69b28fefd6764903432735e8d1e40d6e462641fc";
        };
      };
    instance-identity = mkJenkinsPlugin {
      name = "instance-identity";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/instance-identity/173.va_37c494ec4e5/instance-identity.hpi";
        sha256 = "0e240647854068c21fec3f3dbe449bf1a29356a1dea87646cb1ac813bec37c79";
        };
      };
    ionicons-api = mkJenkinsPlugin {
      name = "ionicons-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ionicons-api/56.v1b_1c8c49374e/ionicons-api.hpi";
        sha256 = "4a6176a2169481fec295c900a6291b3b809b8dd17805868abbdc8a7a322169ca";
        };
      };
    jackson2-api = mkJenkinsPlugin {
      name = "jackson2-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jackson2-api/2.15.2-350.v0c2f3f8fc595/jackson2-api.hpi";
        sha256 = "41c78ad46a4ce3fc40b353bf4cd425aa18d2a4dbfe826624c62834e4b19fdaad";
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
        url = "https://updates.jenkins-ci.org/download/plugins/javadoc/233.vdc1a_ec702cff/javadoc.hpi";
        sha256 = "9a546d376e92bc1f8fe68d8d7628388deb7a043c0dfe0836f39afe8eccccefa6";
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
        url = "https://updates.jenkins-ci.org/download/plugins/jenkins-design-language/1.27.4/jenkins-design-language.hpi";
        sha256 = "ef7fcf45ca07736d01c127fb914b219a73451e7df9ebbb2e6df4522f319eb141";
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
        url = "https://updates.jenkins-ci.org/download/plugins/job-dsl/1.84/job-dsl.hpi";
        sha256 = "2c1b741a7cdd2630aeb8bed60b9abb60eb286d1d00e9c1df4a73f58b352220fe";
        };
      };
    jquery3-api = mkJenkinsPlugin {
      name = "jquery3-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jquery3-api/3.7.0-1/jquery3-api.hpi";
        sha256 = "1318866ddd43d38a92af93fddf837526d430a0a9123d54e442295edfece1b4e5";
        };
      };
    jsch = mkJenkinsPlugin {
      name = "jsch";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jsch/0.2.8-65.v052c39de79b_2/jsch.hpi";
        sha256 = "1267c1d0f48ee3c00fb325a5c53ef5ec73eae4daeab27c5bf55f235069055abe";
        };
      };
    junit = mkJenkinsPlugin {
      name = "junit";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/junit/1217.v4297208a_a_b_ce/junit.hpi";
        sha256 = "041d2a0de08b62d663597e1a03f50bf11b94c25540c3ee9aa02e942265b148ce";
        };
      };
    mailer = mkJenkinsPlugin {
      name = "mailer";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mailer/457.v3f72cb_e015e5/mailer.hpi";
        sha256 = "3a4ed44e4c1460e2b54a08747866f7ec0f4119b2221313f6b5302806eeac77f4";
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
        url = "https://updates.jenkins-ci.org/download/plugins/matrix-project/789.v57a_725b_63c79/matrix-project.hpi";
        sha256 = "d5817fd03c36f0781e19468222df6d98d66817ed34670bfe271682006030d1b8";
        };
      };
    maven-plugin = mkJenkinsPlugin {
      name = "maven-plugin";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/maven-plugin/3.22/maven-plugin.hpi";
        sha256 = "6b5bdb9e5973befb29b1cad67e580b54e61326db6059af31cf0dfb5dbd14ec6d";
        };
      };
    metrics = mkJenkinsPlugin {
      name = "metrics";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/metrics/4.2.18-439.v86a_20b_a_8318b_/metrics.hpi";
        sha256 = "2905a66b003265760209d4cb57827d21aad905f05be4d5cc5696ed414438cb04";
        };
      };
    mina-sshd-api-common = mkJenkinsPlugin {
      name = "mina-sshd-api-common";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mina-sshd-api-common/2.10.0-69.v28e3e36d18eb_/mina-sshd-api-common.hpi";
        sha256 = "50090b0f09294b051c2415311a5fe8a1c602f2e515b2609936eead5e5a164ceb";
        };
      };
    mina-sshd-api-core = mkJenkinsPlugin {
      name = "mina-sshd-api-core";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mina-sshd-api-core/2.10.0-69.v28e3e36d18eb_/mina-sshd-api-core.hpi";
        sha256 = "2414182b5cc988a6d28fee6a35286e95bf7b841749c3b27c979021f88277890e";
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
        url = "https://updates.jenkins-ci.org/download/plugins/okhttp-api/4.11.0-145.vcb_8de402ef81/okhttp-api.hpi";
        sha256 = "7e51ef23cf2b077d04b7aaaaa4a71210e72948be6514138388ce7451deae6e71";
        };
      };
    parameterized-trigger = mkJenkinsPlugin {
      name = "parameterized-trigger";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.46/parameterized-trigger.hpi";
        sha256 = "b7807a1dd4ffc44ec446835f8d42b33b5d0456b44093a602783f553aa4003100";
        };
      };
    pipeline-build-step = mkJenkinsPlugin {
      name = "pipeline-build-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-build-step/496.v2449a_9a_221f2/pipeline-build-step.hpi";
        sha256 = "b7a18873c2dd130e3b980361039141d5ea426f82f4f8c357c3ccce2334f3cf38";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-graph-view/191.vc6da_9d3eb_70a/pipeline-graph-view.hpi";
        sha256 = "f8fc6bbf5ab20efa2634d4f7dac968e3cf9f61a45ec68228acb3b6ac029739d4";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-input-step/468.va_5db_051498a_4/pipeline-input-step.hpi";
        sha256 = "b7963d5a70f50dbe9b0c89caef74a45575b366d8cc5edc3f2536ed8c197c6f47";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-api/2.2141.v5402e818a_779/pipeline-model-api.hpi";
        sha256 = "c1ff4991e38679db76347560a602ec2ba293f5461659ba07ea677860ecfcdfec";
        };
      };
    pipeline-model-definition = mkJenkinsPlugin {
      name = "pipeline-model-definition";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-definition/2.2141.v5402e818a_779/pipeline-model-definition.hpi";
        sha256 = "7bc6f03b6eda45f0a3819d535cfccf589984f593cd5bf18f077d6b57d35dc5a5";
        };
      };
    pipeline-model-extensions = mkJenkinsPlugin {
      name = "pipeline-model-extensions";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-extensions/2.2141.v5402e818a_779/pipeline-model-extensions.hpi";
        sha256 = "853c54c2d4a5cb39291d6bff6ddff379259b5a4575588240b1dda116c3d2ab31";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-stage-tags-metadata/2.2141.v5402e818a_779/pipeline-stage-tags-metadata.hpi";
        sha256 = "3dfdae448c205e9e1a37151f868f25e5e6a0eaea6e11381f5930bd7bb2fe6ae3";
        };
      };
    pipeline-utility-steps = mkJenkinsPlugin {
      name = "pipeline-utility-steps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-utility-steps/2.16.0/pipeline-utility-steps.hpi";
        sha256 = "dfe39235dffbe5bfd10c39fb652e313dd9c0b3b7e44dbf275326eb64da94c754";
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
        url = "https://updates.jenkins-ci.org/download/plugins/plugin-util-api/3.3.0/plugin-util-api.hpi";
        sha256 = "737342c3a1ef81ede07bc05019b0493b3246ba95ddabdafc6d4a32ddcf6f971d";
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
        url = "https://updates.jenkins-ci.org/download/plugins/rebuild/320.v5a_0933a_e7d61/rebuild.hpi";
        sha256 = "9b09a256f8a81edc984b688de07c795c22122585c5ce0148e703d20cbce4dfd8";
        };
      };
    run-condition = mkJenkinsPlugin {
      name = "run-condition";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/run-condition/1.6/run-condition.hpi";
        sha256 = "37dcb357578a44e684aa3bef9140bc6d90177cc4088fefdeba4eeb5de517534c";
        };
      };
    scm-api = mkJenkinsPlugin {
      name = "scm-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/scm-api/676.v886669a_199a_a_/scm-api.hpi";
        sha256 = "c8cc7b2120d25977cefc2fa6cc3830be034971e63f5009aee516d984025a837a";
        };
      };
    script-security = mkJenkinsPlugin {
      name = "script-security";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/script-security/1251.vfe552ed55f8d/script-security.hpi";
        sha256 = "89f3074a6bb2e31ed4c33ac5ea71ee91aa3783f55d9580e8ffbc13873e9a7923";
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
        url = "https://updates.jenkins-ci.org/download/plugins/subversion/2.17.2/subversion.hpi";
        sha256 = "b2f304ba5a4623b529b63e00fba6891d00043ce47bd544340a485853c78494db";
        };
      };
    support-core = mkJenkinsPlugin {
      name = "support-core";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/support-core/1328.vb_4e66d4d525c/support-core.hpi";
        sha256 = "92babe29d9d97e1c66005f3334ca377bed73b64cb36eb070996b166fbd32c04b";
        };
      };
    theme-manager = mkJenkinsPlugin {
      name = "theme-manager";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/theme-manager/193.vcef22f6c5f2b_/theme-manager.hpi";
        sha256 = "d667cc84c04c9faa8808c3fc68f0b864c258ab411bad5905b996f9f951a7c61e";
        };
      };
    token-macro = mkJenkinsPlugin {
      name = "token-macro";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/token-macro/359.vb_cde11682e0c/token-macro.hpi";
        sha256 = "6071f7fe48de5bbdd662ca0c2be252ab85c559cde8d3a0b6084a8b880c46d043";
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
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-api/1232.v1679fa_2f0f76/workflow-api.hpi";
        sha256 = "91523f1ce2d1d66b09446c83e48fbb671c65e496ddf6e4455ca2241a5bd92d55";
        };
      };
    workflow-basic-steps = mkJenkinsPlugin {
      name = "workflow-basic-steps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-basic-steps/1017.vb_45b_302f0cea_/workflow-basic-steps.hpi";
        sha256 = "b9f7d422d9d651fd872cda7b7cf5c1d6d2667868ffeace58be7e70fee719ce28";
        };
      };
    workflow-cps = mkJenkinsPlugin {
      name = "workflow-cps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-cps/3705.va_6a_c2775a_c17/workflow-cps.hpi";
        sha256 = "30c58a8dcba23ac48828e9009bcc9e97cc5dc56dfa58139274880b79db9f9483";
        };
      };
    workflow-durable-task-step = mkJenkinsPlugin {
      name = "workflow-durable-task-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-durable-task-step/1247.v7f9dfea_b_4fd0/workflow-durable-task-step.hpi";
        sha256 = "bded6242ed6a8112a6afca547ea5ffb13ea34da708054a84376b7bdc7aed1a54";
        };
      };
    workflow-job = mkJenkinsPlugin {
      name = "workflow-job";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-job/1316.vd2290d3341a_f/workflow-job.hpi";
        sha256 = "5019f44ee209d1153c7b5f59ec43e3d60df57bfff3a1e50bf3832cefe07438c0";
        };
      };
    workflow-multibranch = mkJenkinsPlugin {
      name = "workflow-multibranch";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-multibranch/756.v891d88f2cd46/workflow-multibranch.hpi";
        sha256 = "f3f690324e297c8f263ac21b0a3daa5d60877a2214f6eca2d28d4946d97964b8";
        };
      };
    workflow-scm-step = mkJenkinsPlugin {
      name = "workflow-scm-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-scm-step/415.v434365564324/workflow-scm-step.hpi";
        sha256 = "500720bf8a634363c79ae16d56b88493c211fdb33e163b5d17fb52a85f53508e";
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