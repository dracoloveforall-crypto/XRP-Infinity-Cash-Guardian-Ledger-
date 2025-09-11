import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtMultimedia 6.0
import org.kde.plasma.plasmoid 2.0

Item {
    id: engine

    property var cryptoData: ({})
    property var userHoldings: ({})
    property double totalInvestment: 0
    property double totalCurrentValue: 0
    property double totalProfitLoss: 0
    property double previousTotalProfitLoss: 0
    property bool firstUpdate: true

    signal dataUpdated()

    function updateCryptoData(data) {
        cryptoData = data;
        var oldProfitLoss = totalProfitLoss;
        calculatePortfolio();
        dataUpdated();

        if (!firstUpdate) {
            checkForSoundNotifications(oldProfitLoss, totalProfitLoss);
        }
        firstUpdate = false;
    }

    function calculatePortfolio() {
        totalInvestment = 0;
        totalCurrentValue = 0;
        totalProfitLoss = 0;

        try {
            userHoldings = JSON.parse(plasmoid.configuration.portfolio || "{}");
        } catch (e) {
            userHoldings = {};
            console.log("Error parsing portfolio:", e);
        }

        for (const symbol in userHoldings) {
            if (userHoldings.hasOwnProperty(symbol)) {
                const holding = userHoldings[symbol];
                const crypto = cryptoData[symbol];

                if (crypto) {
                    const amount = holding.amount || 0;
                    const invested = holding.invested || 0;
                    const currentValue = amount * crypto.price;
                    const profitLoss = currentValue - invested;

                    totalInvestment += invested;
                    totalCurrentValue += currentValue;
                    totalProfitLoss += profitLoss;
                }
            }
        }

        totalInvestment = parseFloat(totalInvestment.toFixed(2));
        totalCurrentValue = parseFloat(totalCurrentValue.toFixed(2));
        totalProfitLoss = parseFloat(totalProfitLoss.toFixed(2));
    }

    function checkForSoundNotifications(oldProfitLoss, newProfitLoss) {
        if (!plasmoid.configuration.notificationsEnabled) return;
        if (totalInvestment <= 0) return;

        var oldPercentage = (oldProfitLoss / totalInvestment) * 100;
        var newPercentage = (newProfitLoss / totalInvestment) * 100;
        var percentageChange = Math.abs(newPercentage - oldPercentage);

        if (percentageChange >= 0.1) {
            if (newProfitLoss > oldProfitLoss && plasmoid.configuration.gainSound) {
                playSound(plasmoid.configuration.gainSound);
            } else if (newProfitLoss < oldProfitLoss && plasmoid.configuration.lossSound) {
                playSound(plasmoid.configuration.lossSound);
            }
        }
    }

    function playSound(soundFile) {
        if (!soundFile || soundFile === "") return;

        try {
            var audio = Qt.createQmlObject(`
            import QtMultimedia
            MediaPlayer {
                source: "${soundFile}"
                audioOutput: AudioOutput { volume: 0.7 }
                onPlaybackStateChanged: {
                    if (playbackState === MediaPlayer.StoppedState) { destroy(); }
                }
            }`, engine, "CryptoEngineSoundPlayer");
            audio.play();
        } catch (error) {
            console.error("Error playing sound:", error, soundFile);
        }
    }

    function fetchData() {
        var cryptoList = plasmoid.configuration.cryptoList;
        if (!cryptoList || cryptoList.trim() === "") {
            useMockData(["BTC", "ETH"]);
            return;
        }

        var symbols = cryptoList.split(',').map(s => s.trim()).filter(s => s !== '');
        fetchRealData(symbols).then(function(data) {
            updateCryptoData(data);
        }).catch(function(error) {
            console.log("API error, using mock data:", error);
            useMockData(symbols);
        });
    }

    function fetchRealData(symbols) {
        return new Promise(function(resolve, reject) {
            function getFullName(symbol) {
                var names = {
                    "BTC": "Bitcoin", "ETH": "Ethereum", "XRP": "Ripple", "SOL": "Solana",
                    "XMR": "Monero", "WLFI": "World Liberty Financial", "ENA": "Ethena",
                    "SOMI": "Somi", "HYPE": "Hyperion", "PUMP": "Pump"
                };
                return names[symbol.toUpperCase()] || symbol;
            }

            var coinIds = symbols.map(function(symbol) {
                return getCoinGeckoId(symbol);
            }).join(',');

            var apiUrl = "https://api.coingecko.com/api/v3/simple/price?ids=" + coinIds +
            "&vs_currencies=usd&include_24hr_change=true";

            console.log("Fetching from:", apiUrl);

            var xhr = new XMLHttpRequest();
            xhr.open("GET", apiUrl, true);
            xhr.timeout = 10000;

            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        try {
                            var data = JSON.parse(xhr.responseText);
                            console.log("API Response:", JSON.stringify(data));
                            var result = {};

                            symbols.forEach(function(symbol) {
                                var coinId = getCoinGeckoId(symbol);
                                console.log("Looking for:", symbol, "ID:", coinId);

                                if (data[coinId]) {
                                    result[symbol] = {
                                        name: getFullName(symbol),
                                            price: data[coinId].usd,
                                            change24h: data[coinId].usd_24h_change || 0
                                    };
                                    console.log("Found data for", symbol, "Price:", result[symbol].price);
                                } else {
                                    console.log("No data found for:", symbol, "with ID:", coinId, "Available IDs:", Object.keys(data));
                                    result[symbol] = {
                                        name: getFullName(symbol),
                                            price: Math.random() * 100,
                                            change24h: (Math.random() - 0.1) * 10
                                    };
                                }
                            });

                            resolve(result);
                        } catch (e) {
                            console.error("Parse error:", e, "Response:", xhr.responseText);
                            reject("Parse error: " + e);
                        }
                    } else {
                        console.error("HTTP error:", xhr.status, "Response:", xhr.responseText);
                        reject("HTTP error: " + xhr.status);
                    }
                }
            };

            xhr.ontimeout = function() {
                console.error("Request timeout");
                reject("Request timeout");
            };

            xhr.onerror = function() {
                console.error("Network error");
                reject("Network error");
            };

            xhr.send();
        });
    }

    function getCoinGeckoId(symbol) {
        var mapping = {
            "BTC": "bitcoin",
            "ETH": "ethereum",
            "XRP": "ripple",
            "SOL": "solana",
            "XMR": "monero",
            "WLFI": "world-liberty-financial",
            "ENA": "ethena",
            "SOMI": "somi",
            "HYPE": "hyperion",
            "PUMP": "pump",
            "BNB": "binance-coin",
            "ADA": "cardano",
            "DOGE": "dogecoin",
            "DOT": "polkadot",
            "MATIC": "polygon",
            "LTC": "litecoin",
            "AVAX": "avalanche",
            "LINK": "chainlink",
            "ATOM": "cosmos",
            "XLM": "stellar",
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
            "USDT": "tether"
        };

        var upperSymbol = symbol.toUpperCase();
        return mapping[upperSymbol] || upperSymbol.toLowerCase();
    }

    function useMockData(symbols) {
        var mockData = {};
        symbols.forEach(function(symbol) {
            mockData[symbol] = {
                name: getFullName(symbol),
                        price: Math.random() * 10000,
                        change24h: (Math.random() - 0.1) * 10
            };
        });
        updateCryptoData(mockData);
    }

    Timer {
        id: updateTimer
        interval: plasmoid.configuration.updateInterval * 1000
        running: true
        repeat: true
        onTriggered: fetchData()
    }

    Component.onCompleted: {
        try {
            userHoldings = JSON.parse(plasmoid.configuration.portfolio || "{}");
        } catch (e) {
            userHoldings = {};
        }
        fetchData();
    }
}
