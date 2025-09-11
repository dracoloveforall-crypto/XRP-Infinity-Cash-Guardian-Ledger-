var root;
var dataSource;

function init(widget) {
    root = widget;

    // Create a data source for HTTP requests
    dataSource = Qt.createQmlObject('import org.kde.plasma.core 2.0 as PlasmaCore; PlasmaCore.DataSource { engine: "executable" }', root, "HttpDataSource");
    dataSource.connectedSources = [];

    dataSource.onNewData = function(sourceName, data) {
        if (data["exit code"] > 0) {
            console.error("Error fetching data:", data.stderr);
            return;
        }


        var cryptoList = sourceName.split('|')[1].split(',');
        var cryptoData = {};

        cryptoList.forEach(function(symbol) {
            var cleanSymbol = symbol.trim().toUpperCase();
            if (cleanSymbol) {
                cryptoData[cleanSymbol] = {
                    name: getFullName(cleanSymbol),
                           price: Math.random() * 10000,
                           change24h: (Math.random() - 0.5) * 10,
                           change7d: (Math.random() - 0.5) * 20
                };
            }
        });

        if (root.updateCryptoData) {
            root.updateCryptoData(cryptoData);
        }

        // Disconnect after receiving data
        dataSource.disconnectSource(sourceName);
    };
}

function fetchCryptoData(cryptoList) {
    if (cryptoList.length === 0) return;


    var command = "echo 'mock data for: " + cryptoList.join(',') + "'";
    var sourceName = "crypto|" + cryptoList.join(',');

    dataSource.connectSource(sourceName, command, 30000);
}

function getFullName(symbol) {
    var names = {
        "BTC": "bitcoin",
        "ETH": "ethereum",
        "BNB": "binance-coin",
        "XRP": "xrp",
        "ADA": "cardano",
        "SOL": "solana",
        "DOGE": "dogecoin",
        "DOT": "polkadot",
        "MATIC": "polygon",
        "LTC": "litecoin",
        "AVAX": "avalanche",
        "LINK": "chainlink",
        "ATOM": "cosmos",
        "XLM": "stellar",
        "XMR": "monero",
        "ETC": "ethereum-classic",
        "BCH": "bitcoin-cash",
        "ALGO": "algorand",
        "FIL": "filecoin",
        "ICP": "internet-computer",
        "VET": "vechain",
        "XTZ": "tezos",
        "THETA": "theta-network",
        "AAVE": "aave",
        "EOS": "eos",
        "MKR": "maker",
        "GRT": "the-graph",
        "STX": "stacks",
        "BSV": "bitcoin-sv",
        "MIOTA": "iota",
        "NEO": "neo",
        "FTM": "fantom",
        "ZEC": "zcash",
        "RUNE": "thorchain",
        "KSM": "kusama",
        "WAVES": "waves",
        "BAT": "basic-attention-token",
        "COMP": "compound",
        "YFI": "yearn-finance",
        "SNX": "synthetix-network-token",
        "CHZ": "chiliz",
        "ENJ": "enjincoin",
        "HT": "huobi-token",
        "KLAY": "klaytn",
        "CRV": "curve-dao-token",
        "NEAR": "near",
        "MANA": "decentraland",
        "QTUM": "qtum",
        "ONE": "harmony",
        "ZIL": "zilliqa",
        "SC": "siacoin",
        "BTT": "bittorrent",
        "HNT": "helium",
        "AMP": "amp-token",
        "RVN": "ravencoin",
        "XEM": "nem",
        "CELO": "celo",
        "DASH": "dash",
        "OMG": "omisego",
        "UMA": "uma",
        "ANKR": "ankr",
        "ICX": "icon",
        "0x": "0x",
        "AR": "arweave",
        "LRC": "loopring",
        "NEXO": "nexo",
        "REN": "republic-protocol",
        "ZRX": "0x",
        "BAND": "band-protocol",
        "ONT": "ontology",
        "IOST": "iostoken",
        "KNC": "kyber-network-crystal",
        "STORJ": "storj",
        "REP": "augur",
        "SRM": "serum",
        "CEL": "celsius-network-token",
        "VGX": "voyager-token",
        "SUSHI": "sushi",
        "OCEAN": "ocean-protocol",
        "BAL": "balancer",
        "NU": "nucypher",
        "FET": "fetch-ai",
        "RSR": "reserve-rights-token",
        "CVC": "civic",
        "SKL": "skale-network",
        "DGB": "digibyte",
        "XVG": "verge",
        "GLM": "golem",
        "SNT": "status",
        "POLY": "polymath-network",
        "PERP": "perpetual-protocol",
        "RLC": "iexec-rlc",
        "ORN": "orion-protocol",
        "TOMO": "tomochain",
        "OXT": "orchid-protocol",
        "BADGER": "badger-dao",
        "KAVA": "kava",
        "CTSI": "cartesi",
        "MLN": "melon",
        "API3": "api3",
        "ACH": "alchemy-pay",
        "TRB": "tellor",
        "FORTH": "ampleforth-governance-token",
        "JST": "just",
        "TWT": "trust-wallet-token",
        "LSK": "lisk",
        "ARDR": "ardor",
        "POWR": "power-ledger",
        "STEEM": "steem",
        "HIVE": "hive-blockchain",
        "DENT": "dent",
        "HOT": "holotoken",
        "VTHO": "vethor-token",
        "FUN": "funfair",
        "GNO": "gnosis",
        "NMR": "numeraire",
        "GAS": "gas",
        "PAX": "paxos-standard-token",
        "USDP": "pax-dollar",
        "TUSD": "true-usd",
        "GUSD": "gemini-dollar",
        "DAI": "dai",
        "USDC": "usd-coin",
        "WLFI": "world-liberty-financial",
        "USDT": "tether",
        "ENA": "ethena",
        "SOMI": "somi",
        "HYPE": "hyperion",
        "PUMP": "pump"
    };

    return names[symbol] || symbol;
}
