pragma solidity = 0.5.0;
import "../drugaccesscontrol/ProducerRole.sol";
import "../drugaccesscontrol/RetailerRole.sol";
import "../drugaccesscontrol/ConsumerRole.sol";
import "../drugcore/Ownable.sol";

contract SupplyChain is
    ProducerRole,
    RetailerRole,
    ConsumerRole,
    Ownable
{

    // Define 'owner' defined by ownable
    //address payable owner;

    // Define a variable called 'upc' for Universal Product Code (UPC)
    uint  upc;

    // Define a variable called 'sku' for Stock Keeping Unit (SKU)
    uint  sku;

    // Define a variable called 'drugID' for indentifying drugs.
    uint  drugID;

    // Define a public mapping 'drugs' that maps the drugID to a wine.
    mapping (uint => Drug) drugs;

    // Define a public mapping 'itemsHistory' that maps the drugID to an array of TxHash,
    // that track its journey through the supply chain -- to be sent from DApp.
    mapping (uint => string[]) drugsHistory;

    // Define enum 'DrugState' with the following values:
    enum DrugState
    {
        Produced,  // 0
        ForSale,    // 1
        Sold       // 2
    }

    //TODO: set default states for drugs and items

    // Define a struct for drugs
    struct Drug {
        uint drugId; // unique ID of drugs
        address payable ownerID;  // Metamask-Ethereum address of the current owner as the product moves through different stages
        address payable producerID; // Metamask-Ethereum address of the Grower
        string  producerName; // Grower Name
        string  producerInformation;  // Grower Information
        uint    drugPrice; // Product Price
        DrugState   drugState;  // Drug State as represented in the enum above
        bool exist;
    }

    // Define events for drugs
    event DrugProduced(uint drugId);
    event DrugForSale(uint drugId);
    event DrugSold(uint drugId);

    // Define a modifer that verifies the Caller
    modifier verifyCaller (address _address) {
        require(msg.sender == _address);
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnough(uint _price) {
        require(msg.value >= _price,
            "Unsufficient fund");
        _;
    }

    modifier checkDrugValue(uint _drugID) {
        _;
        uint _price = drugs[_drugID].drugPrice;
        uint amountToReturn = msg.value - _price;
        drugs[_drugID].ownerID.transfer(amountToReturn);
    }

    // Define a modifier that checks the price and refunds the remaining balance
    modifier checkValue(uint _upc) {
        _;
        uint _price = items[_upc].productPrice;
        uint amountToReturn = msg.value - _price;
        items[_upc].ownerID.transfer(amountToReturn);
    }

    // Define a modifier that check if drug already exists.
    modifier drugAlreadyExists(uint _drugID) {
        Drug memory _drug = drugs[_drugID];
        require(!_drug.exist, "Drug ID already exists.");
        _;
    }

    // Define a modifier that checks if an drugs.drugState of a drugID is Harvested
    modifier drugProduced(uint _drugId) {
        require(drugs[_drugId].drugState == DrugState.Produced,
            "Drug is not yet produced");
        _;
    }

    // Define a modifier that checks if an item.drugState of a upc is ForSale
    modifier drugForSale(uint _drugId) {
        require(drugs[_drugId].drugState == DrugState.ForSale,
            "Drug is not for sale");
        _;
    }

    // Define a modifier that checks if an item.drugState of a upc is Sold
    modifier drugSold(uint _drugId) {
        require(drugs[_drugId].drugState == DrugState.Sold,
            "Drug is not sold");
        _;
    }

    // In the constructor set 'owner' to the address that instantiated the contract
    // and set 'sku' to 1
    // and set 'upc' to 1
    // drugID to 1
    // the identifier are simplified here
    // as we should also use the client company prefix for generating UPC
    constructor() public payable {
        //payableOwner = msg.sender; see Ownable
        sku = 1;
        upc = 1; // for simpicity we'll use this
        // GS1 guidelines said that UPC
        // applies to branded products only
        // so we use a simple ID
        drugID = 1;
    }

    // Define a function 'kill' if required
    // Either set a new address payable in constructor
    // or cast to payable address the owner()
    function kill() public onlyOwner {
        address payable owng = address(uint160(owner()));
        if (msg.sender == owner()) {
            selfdestruct(owng);
        }
    }

    /////////////////////////
    /// DRUGS OPERATIONS ///
    /////////////////////////

    // Define a function 'produceDrugs' that allows a producer to mark drugs 'Produced'
    function produceDrugs(
        string memory _producerName,
        string memory _producerInformation,
        string memory _drugVariery)
    public
    onlyProducer
    drugAlreadyExists(drugID)
    {
        // Add the new drugs
        uint _drugID = drugID;
        drugs[_drugID] = Drug(
            drugID,
            msg.sender,
            msg.sender,
            _producerName,
            _producerInformation,
            0,
            DrugState.Produced,
            _drugVariery,
            true
        );
        // Increment drugID
        drugID = drugID + 1;
        // Emit the appropriate event
        emit DrugProduced(_drugID);
    }

    // Let a grower that owns havested drugs to put them for sale
    function addDrugsForSale(uint _drugID, uint _drugPrice)
    public
    onlyProducer
    verifyCaller(drugs[_drugID].ownerID)
    {
        Drug storage drug = drugs[_drugID];
        drug.drugState = DrugState.ForSale;
        drug.drugPrice = _drugPrice;
        emit DrugForSale(_drugID);
    }

    function buyDrugs(uint _drugID)
    public
    payable
    onlyProducer
    drugForSale(_drugID)
    paidEnough(drugs[_drugID].drugPrice)
    checkDrugValue(_drugID)
    {
        Drug storage drug = drugs[_drugID];
        drug.drugState = DrugState.Sold;
        uint _drugPrice = drug.drugPrice;
        drug.ownerID = msg.sender;
        drug.producerID.transfer(_drugPrice);
        emit DrugSold(_drugID);
    }

    function buyWine(uint _upc)
    public
    payable
    onlyWholesaler
    wineForSale(_upc)
    paidEnough(items[_upc].productPrice)
    checkValue(_upc)
    {
        Wine storage wine = items[_upc];
        wine.wholesalerID = msg.sender; // Update to wholesaler
        uint _productPrice = wine.productPrice;
        wine.wineState = WineState.Sold;
        address payable recipient = wine.ownerID;
        wine.ownerID = msg.sender;
        recipient.transfer(_productPrice);
        emit WineSold(_upc);
    }

    // fetchWine - 3 functions - stack too deep compilation error
    function fetchWineOne(uint _upc) public view returns (
        uint wineSku,
        uint wineUpc,
        address payable ownerID,
        address payable producerID,
        uint productPrice,
        WineState wineState,
        address wholesalerID,
        address retailerID,
        address consumerID
    ) {
        Wine memory wine = items[_upc];
        wineSku = wine.sku;
        wineUpc = wine.upc;
        ownerID = wine.ownerID;
        producerID = wine.producerID;
        productPrice = wine.productPrice;
        wineState = wine.wineState;
        wholesalerID = wine.wholesalerID;
        retailerID = wine.retailerID;
        consumerID = wine.consumerID;
    }

}
