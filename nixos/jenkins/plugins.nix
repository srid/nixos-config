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
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-commons/1.27.5/blueocean-commons.hpi";
        sha256 = "838f617ec7b3a43a8767fec07d7b76c2f9b685781fb6aae11596f758cde1fe0f";
        };
      };
    blueocean-core-js = mkJenkinsPlugin {
      name = "blueocean-core-js";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-core-js/1.27.5/blueocean-core-js.hpi";
        sha256 = "a92ae7a25424aabc04319748a13926946fc762f8a416449eb233016e86911a03";
        };
      };
    blueocean-rest = mkJenkinsPlugin {
      name = "blueocean-rest";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-rest/1.27.5/blueocean-rest.hpi";
        sha256 = "7bb7f3a00279ee8fba8d51a9f2fa89fb2fcbc42acf2eb82d156bb2e2d332c971";
        };
      };
    blueocean-web = mkJenkinsPlugin {
      name = "blueocean-web";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/blueocean-web/1.27.5/blueocean-web.hpi";
        sha256 = "1975f87416597da66e3141b4bb2a90fa225518be8effecba8a35fcf652837818";
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
        url = "https://updates.jenkins-ci.org/download/plugins/caffeine-api/3.1.8-133.v17b_1ff2e0599/caffeine-api.hpi";
        sha256 = "a6c614655bc507345bf16b5c4615bb09b1a20f934c9bf0b15c02ccea4a5c0400";
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
        url = "https://updates.jenkins-ci.org/download/plugins/cloudbees-folder/6.846.v23698686f0f6/cloudbees-folder.hpi";
        sha256 = "11553ac107e3b48913db1110df7884cc064ecf68c32298fdcbc2d56f01d3c583";
        };
      };
    command-launcher = mkJenkinsPlugin {
      name = "command-launcher";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/command-launcher/106.vb_a_b_8f751309c/command-launcher.hpi";
        sha256 = "9a901b850301f07b6491c626f74097ecdcce37d73403d9d95d4bc6f430bf0c2a";
        };
      };
    commons-lang3-api = mkJenkinsPlugin {
      name = "commons-lang3-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/commons-lang3-api/3.13.0-62.v7d18e55f51e2/commons-lang3-api.hpi";
        sha256 = "e27bbec4d37f26e7da0d0732b241ad0eb2b60826c3f7521808b1442727f54858";
        };
      };
    commons-text-api = mkJenkinsPlugin {
      name = "commons-text-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/commons-text-api/1.10.0-68.v0d0b_c439292b_/commons-text-api.hpi";
        sha256 = "d21389b3d63edd5779315559632186b7b1ea9ae772b16dc37bb51002998b5464";
        };
      };
    conditional-buildstep = mkJenkinsPlugin {
      name = "conditional-buildstep";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/conditional-buildstep/1.4.3/conditional-buildstep.hpi";
        sha256 = "d2ce40b86abc42372085ace0a6bb3785d14ae27f0824709dfc2a2b3891a9e8a8";
        };
      };
    config-file-provider = mkJenkinsPlugin {
      name = "config-file-provider";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/config-file-provider/952.va_544a_6234b_46/config-file-provider.hpi";
        sha256 = "035b1879f4e5fd76f3cd05769d98540be89d54cc3a5df18ea2a8ee2eb8192c6e";
        };
      };
    configuration-as-code = mkJenkinsPlugin {
      name = "configuration-as-code";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/configuration-as-code/1670.v564dc8b_982d0/configuration-as-code.hpi";
        sha256 = "09e0ad59612ae42e928106543a93bc4cb3f7f97abc1097aa05d19a6fd0305d07";
        };
      };
    credentials = mkJenkinsPlugin {
      name = "credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials/1271.v54b_1c2c6388a_/credentials.hpi";
        sha256 = "9decbc2d8c62ad6f424426f507966be04b51f95e6bf9f75ed10144fedbcc6685";
        };
      };
    credentials-binding = mkJenkinsPlugin {
      name = "credentials-binding";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials-binding/631.v861c06d062b_4/credentials-binding.hpi";
        sha256 = "c0fdd26b3a48322f7a5c29e6eb9870b32cc118890defe738f59573ce66ae6e80";
        };
      };
    display-url-api = mkJenkinsPlugin {
      name = "display-url-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/display-url-api/2.3.8/display-url-api.hpi";
        sha256 = "bab3256a75c55ab7193b8e5c9f1d5eeb7571f7e8d5b50fdb41a6779905d77110";
        };
      };
    durable-task = mkJenkinsPlugin {
      name = "durable-task";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/durable-task/513.vc48a_a_075a_d93/durable-task.hpi";
        sha256 = "5a4b85d848bf4d3dd87b49e1ec9bf7d4bb38670c22ddba6a62ccc4bdd2c748b1";
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
        url = "https://updates.jenkins-ci.org/download/plugins/font-awesome-api/6.4.0-2/font-awesome-api.hpi";
        sha256 = "f81b62dea7c6feed347df5e0f40e48f9966fd58c690745ed157f0749809e8ad6";
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
        url = "https://updates.jenkins-ci.org/download/plugins/github/1.37.3/github.hpi";
        sha256 = "5bbb837a65f062d6ebe11032605e869d0dc6e37bb38dba73e54b60ede0e97cf7";
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
        url = "https://updates.jenkins-ci.org/download/plugins/github-branch-source/1732.v3f1889a_c475b_/github-branch-source.hpi";
        sha256 = "eec6a26d0d2f8d7d2ad83732260bb069d14a99b18ee19008ec818134c54e443f";
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
        url = "https://updates.jenkins-ci.org/download/plugins/javadoc/243.vb_b_503b_b_45537/javadoc.hpi";
        sha256 = "0dfffce64e478edcdbbfde2df5913be2ff46e5e033daff8bc9bb616ca7528999";
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
        url = "https://updates.jenkins-ci.org/download/plugins/jenkins-design-language/1.27.5/jenkins-design-language.hpi";
        sha256 = "dff5dbc3f5962db4c1df81528e72798172d38e812b068e40073b862b508851fb";
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
        url = "https://updates.jenkins-ci.org/download/plugins/mailer/463.vedf8358e006b_/mailer.hpi";
        sha256 = "e732d5e291b047a423ced942140c4a0cefa08fe4a40dba69ad5c5af53bba593e";
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
        url = "https://updates.jenkins-ci.org/download/plugins/matrix-project/808.v5a_b_5f56d6966/matrix-project.hpi";
        sha256 = "c8f03bb421e0359d7d7b2501ceca602bc128f2b7a8092449630665f2924f57b4";
        };
      };
    maven-plugin = mkJenkinsPlugin {
      name = "maven-plugin";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/maven-plugin/3.23/maven-plugin.hpi";
        sha256 = "f412f9701aafa46d8e68dccb046b41745f2116ad91b76b0f35a24f21830097eb";
        };
      };
    metrics = mkJenkinsPlugin {
      name = "metrics";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/metrics/4.2.18-442.v02e107157925/metrics.hpi";
        sha256 = "8c552715237b7bb2b9b6a1b9806d691e4043d5416f732cde2c293b01d361d90f";
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
        url = "https://updates.jenkins-ci.org/download/plugins/okhttp-api/4.11.0-157.v6852a_a_fa_ec11/okhttp-api.hpi";
        sha256 = "1ac8e08914923edcf5e1826b948d6c89f20d9247949105be0869c3e397b79eb6";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-build-step/505.v5f0844d8d126/pipeline-build-step.hpi";
        sha256 = "1163570e8a9b7672e8c2ec5bc779f943baea61d71740896529dfd2e428b94673";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-groovy-lib/671.v07c339c842e8/pipeline-groovy-lib.hpi";
        sha256 = "f500a91c1a1ea05ada16c33667a69d69ccadb787cd0cefdee3f7df1034ccae71";
        };
      };
    pipeline-input-step = mkJenkinsPlugin {
      name = "pipeline-input-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-input-step/477.v339683a_8d55e/pipeline-input-step.hpi";
        sha256 = "b25598cf76c788563ba667c2ab82348842b95db133d378395536f777ee2be00f";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-api/2.2144.v077a_d1928a_40/pipeline-model-api.hpi";
        sha256 = "579e49d96527e09c25e42ff3dc1f320adef7ee0a8e2761de5e10cc1c0f02fcff";
        };
      };
    pipeline-model-definition = mkJenkinsPlugin {
      name = "pipeline-model-definition";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-definition/2.2144.v077a_d1928a_40/pipeline-model-definition.hpi";
        sha256 = "407126434abeaf8db0224c2896b246b36ae165428ba7b53f932dc52b206b73bd";
        };
      };
    pipeline-model-extensions = mkJenkinsPlugin {
      name = "pipeline-model-extensions";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-extensions/2.2144.v077a_d1928a_40/pipeline-model-extensions.hpi";
        sha256 = "fccea0e049b8c0a133ce750df97123fe5ff99d2141beec634e0aa98e6b582fc9";
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
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-stage-tags-metadata/2.2144.v077a_d1928a_40/pipeline-stage-tags-metadata.hpi";
        sha256 = "f67de16861c6fa53b3ef41bd8eaf2f73ca2221daca9dadd8c3164e17f47d94f2";
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
    role-strategy = mkJenkinsPlugin {
      name = "role-strategy";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/role-strategy/680.v3a_6a_1698b_864/role-strategy.hpi";
        sha256 = "164ff2de7f5a3a1b60cf9546a220526ebae6edcf3620a031c3d5445d4a854f63";
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
        url = "https://updates.jenkins-ci.org/download/plugins/script-security/1264.vecf66020eb_7d/script-security.hpi";
        sha256 = "a0ebfa67e66a1adfd84b2c344dc2a42b5372a2e097b32c56a30a400454fd80d3";
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
        url = "https://updates.jenkins-ci.org/download/plugins/ssh-credentials/308.ve4497b_ccd8f4/ssh-credentials.hpi";
        sha256 = "23984ee5cfede3526a13714c82426db6d8e63c5635f9c6aac89a48c246000be2";
        };
      };
    ssh-slaves = mkJenkinsPlugin {
      name = "ssh-slaves";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ssh-slaves/2.916.vd17b_43357ce4/ssh-slaves.hpi";
        sha256 = "27e283eaab9dd5fa250c2ef579a31018cbdfe80db044d2afe2cbdef808f39842";
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
        url = "https://updates.jenkins-ci.org/download/plugins/subversion/2.17.3/subversion.hpi";
        sha256 = "e972712afe0225b4706e38b2352ae11c026b170cc023e68e40e87dfbd9c267a5";
        };
      };
    support-core = mkJenkinsPlugin {
      name = "support-core";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/support-core/1354.v0d622276ca_de/support-core.hpi";
        sha256 = "2bacc2bdf4bd0deb8c8c49f73dc0db7c85b06096f4388672bf3719631e4bb6a3";
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
        url = "https://updates.jenkins-ci.org/download/plugins/token-macro/384.vf35b_f26814ec/token-macro.hpi";
        sha256 = "eb099a1198aec1bdc1b04be7504611367923a467b03b801ea21fb6705bc9991d";
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
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-api/1251.vd4889a_b_0a_065/workflow-api.hpi";
        sha256 = "3f2433a74ab760cb645ba349d1ba4461df9732b18bc292f15823c6bc5f4d099c";
        };
      };
    workflow-basic-steps = mkJenkinsPlugin {
      name = "workflow-basic-steps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-basic-steps/1042.ve7b_140c4a_e0c/workflow-basic-steps.hpi";
        sha256 = "ab0f9d989a1885ae6f5148c9acc6ffcf1667bf427c6d392eaf8cf1cd1b670345";
        };
      };
    workflow-cps = mkJenkinsPlugin {
      name = "workflow-cps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-cps/3731.ve4b_5b_857b_a_d3/workflow-cps.hpi";
        sha256 = "4b79744eb5cb9484c7a451fda9f993ba54bf496b0977b21a8228d754a6ece5d8";
        };
      };
    workflow-durable-task-step = mkJenkinsPlugin {
      name = "workflow-durable-task-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-durable-task-step/1284.v4fcd365b_75b_e/workflow-durable-task-step.hpi";
        sha256 = "337fbbe8f55d82fdec90a8c0f5882c6a6f19330a881f2a663569f6664c540357";
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
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-support/848.v5a_383b_d14921/workflow-support.hpi";
        sha256 = "3872a41ed77581e5c5b22c836849346a8c59c59691b2cd5d892bf4369f7c8502";
        };
      };
    }