/**
 *Submitted for verification at Etherscan.io on 2024-05-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.8.0 <0.9.0;


contract Voting {
    struct Voter {
        address userAddress; 
        uint256 votedTo; 
    }
    struct Candidate {
        uint256 candidateId;
        string name;
        string shortCut;
        string description;
    }

    struct Result {
        uint256 candidateId;
        string name;
        string shortCut;
        string description;
        uint256 voteCount;
    }

    Candidate[] public candidates;
    Voter[] public voters;
    address electionInitiator;
    uint256 public votingStartTime;
    uint256 public votingEndTime;
    mapping(uint256 => Candidate) candidate;
    mapping(address => Voter) private voter;
    mapping(uint256 => uint256) public votesCount;
    mapping(address => bool) public is_in;
    constructor(uint256 vtStartTime_, uint256 vtEndTime_) {
        votingStartTime = vtStartTime_;
        votingEndTime = vtEndTime_;
        electionInitiator = msg.sender;
        Candidate[] memory candidates_ = new Candidate[](3);
        candidates_[0] = Candidate({

            name: unicode"Гуляев Данила",
            shortCut: unicode"Г.Д.",
            candidateId : 1,
            description: unicode""
        });
        candidates_[1] = Candidate({

            name: unicode"Шаров Тимур",
            shortCut: unicode"Ш.Т.",
            candidateId : 2,
            description: unicode""
        });
        candidates_[2] = Candidate({

            name: unicode"Греков Степан",
            shortCut: unicode"Г.С.",
            candidateId : 3,
            description: unicode""
        });
        for (uint256 i = 0; i < candidates_.length; i++) {
            candidate[candidates_[i].candidateId] = candidates_[i];
            candidates.push(candidates_[i]);
        }
        Voter[] memory voters_ = new Voter[](5);
        voters_[0] = Voter({
            userAddress: 0x4FA3d69b1c36C65c4506D674Ec3752e673fe633C,
            votedTo: 0
        });
        is_in[0x4FA3d69b1c36C65c4506D674Ec3752e673fe633C] = true;
        
        voters_[1] = Voter({
            userAddress: 0x960f6C5243971E3438ae828fcc643775F5fA5814,
            votedTo: 0
                });
        is_in[0x960f6C5243971E3438ae828fcc643775F5fA5814] = true;
        
        voters_[2] = Voter({
            userAddress: 0x959FbC98FC3f6457A65d43dfd40e31Fe64a4a037,
            votedTo: 0
        });
        is_in[0x959FbC98FC3f6457A65d43dfd40e31Fe64a4a037] = true;


        voters_[2] = Voter({
            userAddress: 0xf1076A55c516a97AB35724795dEfC3Bef6776Ab9,
            votedTo: 0
        });
        is_in[0xf1076A55c516a97AB35724795dEfC3Bef6776Ab9] = true;
        for (uint256 i = 0; i < voters_.length; i++) {
            voters.push(voters_[i]);
        }
    }
    // Инциаилизация списка голосующих 
    // Функция выводит список людей, записавшихся на голосование
    function getSeeVoters() view public returns (Voter[] memory myset_){
        myset_ = voters;  }
    // функция, позволяющая инициатору обновить время начала голосования
    function updateVtStartTime(uint256 startTime_)
        public isInitiator()
    {
        uint256 currentTime_ = block.timestamp;
        require(votingStartTime > currentTime_);
        votingStartTime = startTime_;
    }
    // функция, позволяющая инциатору продлить время окончания голосования
    function extendVtTime(uint256 endTime_)
        public isInitiator
    {
        uint256 currentTime_ = block.timestamp;
        require(endTime_ > currentTime_);
        require(votingEndTime > currentTime_);
        votingEndTime = endTime_;
    }
    // функция, позволяющая получить список кандидатов
     function getCandidateList()
        public
        view
        returns (Candidate[] memory cc_)
    {
        cc_ = candidates;    
    }
    // функция, позволяющая проголосовать пользователю
        function vote(uint16 candidateId)
        public
        isVotingProcessOpen()
        isVoterEligible()
        haveVoted() returns (uint16 message)
    {
        voter[msg.sender].votedTo = candidateId;
        uint256 voteCount_ = votesCount[candidateId];
        votesCount[candidateId] = voteCount_ + 1;
        message = candidateId;
    }
    // модификатор проверяет, голосовал ли пользователь
    modifier haveVoted(){
        require(voter[msg.sender].votedTo == 0, unicode"Пользователь уже проголосовал!");
        _;
    }
    // модификатор проверяет, закончилось ли голосование
    modifier voteEnded(){
        uint256 currentTime_ = block.timestamp;
        require(votingEndTime < currentTime_, unicode"Голосование еще не закончилось!");
        _;
    }
    // Модификатор проверяет, находится ли подписант сообщения в списке голосующих
    modifier isVoterEligible() {
        require(is_in[msg.sender], unicode"Пользователь не может голосовать, нет в списке!");
        _;
    }
    // Модификатор проверяет, доступно ли голосование на момент подписания сообщения
        modifier isVotingProcessOpen() {
        uint256 currentTime_ = block.timestamp;
        require(currentTime_ >= votingStartTime, unicode"Голосование кончилось!");
        require(currentTime_ <= votingEndTime, unicode"Голосование кончилось!");
        _;
    }
    // Модификатор проверяет, является ли подписант сообщения инициатором голосования
    modifier isInitiator() {
        require(msg.sender == electionInitiator, unicode"Пользователь не Инициатор!");
        _;
    }

    function getResults()
        public
        view
        voteEnded()
        returns (Result[] memory res)
    {
        uint256 currentTime_ = block.timestamp;
        require(votingEndTime < currentTime_);
        Result[] memory resultsList_ = new Result[](
            candidates.length
        );
        for (uint256 i = 0; i < candidates.length; i++) {
            resultsList_[i] = Result({
                name: candidates[i].name,
                shortCut: candidates[i].shortCut,
                candidateId: candidates[i].candidateId,
                description: candidates[i].description,
                voteCount: votesCount[candidates[i].candidateId]
            });
        }
        return resultsList_;
    }

    // функция просмотра времени голосования
    function  getVotingTime() public view
    returns(uint256  st, uint256 et){
        st = votingStartTime;
        et = votingEndTime;
    }

    // функция для определения типа пользователя 0 - наблюдатель; 1 - голосующий; 2 - инициатор(для графического интерфейса)
    function who() public view
        returns(uint256 userType){
            if (msg.sender == electionInitiator)
            {userType == 2;} 
            else if (is_in[msg.sender]) 
            {userType == 1;}
            else 
            {userType==0;}
        }
}