window.onload = async function () {
  // определение криптовалютного кошелька в браузере
  if (window.ethereum) {
      console.log("This is DAppp Environment");
      // запрос на подключение кошелька к веб-странице 
	  var accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      var currentaddress = accounts[0];
	  web3 = new Web3(window.ethereum);
      // инициализация web3 объекта  с указанием смарт-контракта голосования
	  voting = new web3.eth.Contract(abi, '0xE860D079aeC29c0b04781460cd23b5eF5A5f3BDf');
	  // декоративная функция, определяющая тип пользователя и отображающая соответствующий статус в навигации страницы с адресом аккаунта
	  voting.methods.who().call().then((res) => {
		usrInfo = document.getElementById('userType')
		if (res == 1) {usrInfo.textContent = "Голосующий "} else if (res = 2) {usrInfo.textContent = "Инициатор "} else {usrInfo.textContent = "Наблюдатель "}
		usrInfo.textContent += currentaddress; 
		})
  } else {
      alert("Please connect with metamask");
  }
  // функция получения списка кандидатов
  getCandidates = document.getElementById('getCandidates')
  getCandidates.onclick = function(){
  voting.methods.getCandidateList().call().then((res) => {
	var body = document.getElementById('candidateTable');
	body.innerHTML = '';
	// формирование таблицы со списком кандидатов
	var tbl = document.createElement('table');
	tbl.style.width = '100%';
	tbl.setAttribute('border', '1');
	var thd = document.createElement('thead');
	var tbdy = document.createElement('tbody');
	for (var i = 0; i < res.length; i++) {
	  var tr = document.createElement('tr');
	  for (var j = 0; j < res[i].length+1; j++) {
		if (j == res[i].length) {
			var btn = document.createElement('div');
			btn.classList.add('btn', 'btn-secondary');
			btn.textContent = "Голосовать";
			btn.dataset.value = res[i][0];
			// функция голоса
			btn.onclick = function(event) {
				voting.methods.vote(event.target.dataset.value).send({ from: currentaddress}).then(() => {
                    alert("Вы успешно проголосовали!");
                }).catch((err) => {
                    console.log(err);
                })
				alert()
			}
			var td = document.createElement('td');
			td.appendChild(btn);
			tr.appendChild(td);
		} else {
		var td = document.createElement('td');
		td.textContent = res[i][j]
		tr.appendChild(td)
		}
	  }
	  tbdy.appendChild(tr);
	}
	tbl.appendChild(tbdy);
	body.appendChild(tbl)
    }).catch((err) => {
    alert(err);
})
  } 
  // функция получения списка голосующих
  getVoters = document.getElementById('getVoters')
  getVoters.onclick = function(){
  voting.methods.getSeeVoters().call().then((res) => {
    alert(res);
    }).catch((err) => {
    alert(err);
})
  }
  // функция получения времени голосования
  getTime = document.getElementById('getTimers')
  getTime.onclick = function(){
	voting.methods.getVotingTime().call().then((res) => {
	  // перевод временных рамок из формата unix в формат ISO 8601
	  startTime = new Date(res[0]*1e3).toISOString().replace('T', ' ').replace('Z', ' ');
	  endTime = new Date(res[1]*1e3).toISOString().replace('T', ' ').replace('Z', ' ');
	  //  определения поля для отображения времени
	  var date = document.getElementById('toDate');
	  // отображение временных промежутков
	  date.textContent = "Голосование проводится с " + startTime + " до "  + endTime;
	  }).catch((err) => {
	  alert(err);
  })
	} 
// функция получения победителя голосования 
  getResult = document.getElementById('getResult')
  getResult.onclick = function(){
	voting.methods.getResults().call().then((res) => {
		// определения поля для отображения победителя
		var wnr = document.getElementById('candidateTable');
		var winner = res[0];
		for (i = 0; i < res.length; i ++){
			if (res[i][4] > winner[4]){
				// просчет победителя из полученного массива
				winner = res[i];
			}
		}
		// отображение победителя
		wnr.textContent = 'Победитель - ' + winner[1] + ' набравший ' + winner[4] + ' голосов.';
		// направление в консоль полносго списка кандидатов
		console.log(res)
		}).catch((err) => {
		alert(err);
	})
  }
}

abi = [
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "endTime_",
				"type": "uint256"
			}
		],
		"name": "extendVtTime",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "vtStartTime_",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "vtEndTime_",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "startTime_",
				"type": "uint256"
			}
		],
		"name": "updateVtStartTime",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "candidateId",
				"type": "uint16"
			}
		],
		"name": "vote",
		"outputs": [
			{
				"internalType": "uint16",
				"name": "message",
				"type": "uint16"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "candidates",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "candidateId",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "shortCut",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "description",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getCandidateList",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "candidateId",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "shortCut",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "description",
						"type": "string"
					}
				],
				"internalType": "struct Voting.Candidate[]",
				"name": "cc_",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getResults",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "candidateId",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "shortCut",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "description",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "voteCount",
						"type": "uint256"
					}
				],
				"internalType": "struct Voting.Result[]",
				"name": "res",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getSeeVoters",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "userAddress",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "votedTo",
						"type": "uint256"
					}
				],
				"internalType": "struct Voting.Voter[]",
				"name": "myset_",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getVotingTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "st",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "et",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "is_in",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "voters",
		"outputs": [
			{
				"internalType": "address",
				"name": "userAddress",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "votedTo",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "votesCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "votingEndTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "votingStartTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "who",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "userType",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]