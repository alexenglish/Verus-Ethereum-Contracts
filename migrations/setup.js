const MAPPING_ETHEREUM_OWNED = 1;
const MAPPING_VERUS_OWNED = 2;
const MAPPING_PARTOF_BRIDGEVETH = 4;
const MAPPING_ISBRIDGE_CURRENCY = 8;
const TOKEN_LAUNCH = 32;

// These are the notaries iaddresses in hex form.
exports.verusNotariserIDS = ["0x429c5f2039f259c02885972852438731f21fc949",
    "0xcc86752da0c3629b7478c2b542d8b5055efee861",
    "0x9ea954a6086ba4693af454be3bfa34c9af27b6b4",
    "0xc6d8a087e1429b3676913435fb21e42569005ebc",
    "0x5653dfafa45298e7ffdbdbf8efeb3ab3b77f0a71",
    "0xb2f07c93436ff774010a6c9e8fb45206b9236455",
    "0x3c38fb272623533782e16509e7b2d9dec89d6b14",
    "0x66bc28762a7fdf88c0fa80f6c1553ff2260162db",
    "0xaf4934caf6378f429abd8381b4bdf5fbc3dcbc85",
    "0xa003129fd7e52f2770f49984e26aefdac96d10ed",
    "0xe8a86d5683f46dccb7f0815e7defeb489024bb17",
    "0x06632f9e4669f5ec782c37fc15faa6484f7a63dc",
    "0x50eba00f6dfeb95ca8ad9678ec913a944a8fe69e",
    "0xbc933f7babba837fe3291dd84f60084633daec06",
    "0xf2e2a699cebdadb6f18c9bdf735ab2828be99086",
    "0x7069a372dcd437f99abab1f4b3d0be230e2eb286",
    "0x8feb143a407bee56013156669e333b5ffe2361d8",
    "0x6fa063cf74dd44d72cb7021f2c5e51c0a34bfd9e",
    "0x39c893ffa61a12e899f8f255b5e09067922df277"];

// These are the equivelent ETH addresses of the notaries Spending R addresses
exports.verusNotariserSigner = ["0x75201d47A549C39531aD22Fda6A0B2b99B5b61e1",
    "0x50af1B0fda9690C5B50fC6dc1036eC07d4C190e7",
    "0x696921eD978F93558C327d4727e49EE506Da6381",
    "0x9961E69D5B8c229e033143141A4611346C5BCEbb",
    "0xC6b9D17462b6e7c9806E17FFD4F69689A3210EFF",
    "0xAd3C15793c8276A1a9BD6c2A417a6327fd1807cD",
    "0x67583015187C9d23aa2155a89ED8850B093bD0E5",
    "0x1a7D88CeC2FdCb47f8C62024eaFe86050e7302d8",
    "0xec7BAef4303E0d6E64Ff3E9Da2226B8158104d89",
    "0xe2f1b9D1B1FCecb15Eb6b73b652c6F46B70EeC17",
    "0x21022d5e4313cc6fdDFbc55c974ff0E25F93a272",
    "0x296CEe545E270d30fC81D54B318ee8762463DF66",
    "0xA683f1D55635A1D65e003E0aF29a2A128b0c3b8A",
    "0x032a893BBdf3E93465f299142BDc736F5409475E",
    "0xC873792e8223310c24F6a226E38Ebb164A0bA1cE",
    "0x7D3FD8A015631AD5bb12FC6Fa6eDA6dAb30BE8D9",
    "0x64745BC0a92E11c7b0809F042EBAdC92b2b0d014",
    "0xC994C8eDBfa60db9E90665925686CD53cc65Bb64",
    "0x92352245278B8c973209a83B509c19Ef921925B9"];

// These are the equivelent ETH addresses of the notaries Recovery R addresses
exports.verusNotariserRevoker = ["0x75201d47A549C39531aD22Fda6A0B2b99B5b61e1",
    "0x50af1B0fda9690C5B50fC6dc1036eC07d4C190e7",
    "0x696921eD978F93558C327d4727e49EE506Da6381",
    "0x9961E69D5B8c229e033143141A4611346C5BCEbb",
    "0xC6b9D17462b6e7c9806E17FFD4F69689A3210EFF",
    "0xAd3C15793c8276A1a9BD6c2A417a6327fd1807cD",
    "0x67583015187C9d23aa2155a89ED8850B093bD0E5",
    "0x1a7D88CeC2FdCb47f8C62024eaFe86050e7302d8",
    "0xec7BAef4303E0d6E64Ff3E9Da2226B8158104d89",
    "0xe2f1b9D1B1FCecb15Eb6b73b652c6F46B70EeC17",
    "0x21022d5e4313cc6fdDFbc55c974ff0E25F93a272",
    "0x296CEe545E270d30fC81D54B318ee8762463DF66",
    "0xA683f1D55635A1D65e003E0aF29a2A128b0c3b8A",
    "0x032a893BBdf3E93465f299142BDc736F5409475E",
    "0xC873792e8223310c24F6a226E38Ebb164A0bA1cE",
    "0x7D3FD8A015631AD5bb12FC6Fa6eDA6dAb30BE8D9",
    "0x64745BC0a92E11c7b0809F042EBAdC92b2b0d014",
    "0xC994C8eDBfa60db9E90665925686CD53cc65Bb64",
    "0x92352245278B8c973209a83B509c19Ef921925B9"];

// currencies that are defined are in this format:
// iaddress in hex, ERC20 contract, parent, token options, name, ticker, NFTtokenID.

const vrsctest = ["0xA6ef9ea235635E328124Ff3429dB9F9E91b64e2d", 
    "0x0000000000000000000000000000000000000000", 
    "0x0000000000000000000000000000000000000000", 
    MAPPING_VERUS_OWNED + MAPPING_PARTOF_BRIDGEVETH + TOKEN_LAUNCH, 
    "vrsctest",
    "VRSC",
    "0x0000000000000000000000000000000000000000000000000000000000000000"];
	
const bridgeeth = ["0xffEce948b8A38bBcC813411D2597f7f8485a0689", 
    "0x0000000000000000000000000000000000000000", 
    "0xA6ef9ea235635E328124Ff3429dB9F9E91b64e2d", 
    MAPPING_VERUS_OWNED + MAPPING_ISBRIDGE_CURRENCY + TOKEN_LAUNCH, 
    "bridge.vETH", 
    "BETH",
    "0x0000000000000000000000000000000000000000000000000000000000000000"];
	
const usdc = ["0xf0a1263056c30e221f0f851c36b767fff2544f7f", 
    "0x98339D8C260052B7ad81c28c16C0b98420f2B46a", 
    "0xA6ef9ea235635E328124Ff3429dB9F9E91b64e2d", 
    MAPPING_ETHEREUM_OWNED + MAPPING_PARTOF_BRIDGEVETH + TOKEN_LAUNCH, 
    "Testnet USDC", 
    "USDC",
    "0x0000000000000000000000000000000000000000000000000000000000000000"];
	
const veth = ["0x67460C2f56774eD27EeB8685f29f6CEC0B090B00", 
    "0x06012c8cf97bead5deae237070f9587f8e7a266d", 
    "0xA6ef9ea235635E328124Ff3429dB9F9E91b64e2d",
    MAPPING_ETHEREUM_OWNED + MAPPING_PARTOF_BRIDGEVETH + TOKEN_LAUNCH, 
    "Testnet ETH", 
    "ETH",
    "0x0000000000000000000000000000000000000000000000000000000000000000"];

const dai = ["0xcce5d18f305474f1e0e0ec1c507d8c85e7315fdf", 
    "0xB897f2448054bc5b133268A53090e110D101FFf0", 
    "0xA6ef9ea235635E328124Ff3429dB9F9E91b64e2d", 
    MAPPING_ETHEREUM_OWNED + MAPPING_PARTOF_BRIDGEVETH + TOKEN_LAUNCH, 
    "Testnet DAI", 
    "DAI",
    "0x0000000000000000000000000000000000000000000000000000000000000000"];

// Setup the tokens to be launched with the contract here.  Important this must match the vETH definitions.

exports.arrayofcurrencies = [vrsctest, bridgeeth, veth, dai]
