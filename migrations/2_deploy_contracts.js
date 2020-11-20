// const ConvertLib = artifacts.require("ConvertLib");
// const MetaCoin = artifacts.require("MetaCoin");
const MedicationToken = artifacts.require("MedicationToken");
const SupplyChain = artifacts.require("SupplyChain");

module.exports = function(deployer) {
  // deployer.deploy(ConvertLib);
  // deployer.link(ConvertLib, MetaCoin);
  // deployer.deploy(MetaCoin);
  deployer.deploy(MedicationToken)
      .then(()=>{
        return deployer.deploy(SupplyChain, MedicationToken.address)
      });
};
