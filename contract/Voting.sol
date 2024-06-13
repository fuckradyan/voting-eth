// SPDX-License-Identifier: GPL-3.0
pragma experimental ABIEncoderV2;
pragma solidity >=0.8.0 <0.9.0;


contract Voting {
    struct Voter {
        address payable userAddress; 
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
    address electionInitiator;
    uint256 public entryStartTime;
    uint256 public entryEndTime;
    uint256 public votingStartTime;
    uint256 public votingEndTime;
    mapping(uint256 => Candidate) candidate;
    mapping(address => Voter) private voter;
    mapping(uint256 => uint256) public votesCount;
    constructor(uint256  enStartTime_, uint256 enEndTime_, uint256 vtStartTime_, uint256 vtEndTime_) {
       // initializeCandidateDatabase_();
       // initializeVoterDatabase_();
        entryStartTime = enStartTime_;
        entryEndTime = enEndTime_;
        votingStartTime = vtStartTime_;
        votingEndTime = vtEndTime_;
        electionInitiator = msg.sender;
        Candidate[] memory candidates_ = new Candidate[](2);
        candidates_[0] = Candidate({

            name: unicode"",
            shortCut: unicode"",
            candidateId : 1,
            description: unicode""
        });
        candidates_[1] = Candidate({

            name: unicode"",
            shortCut: unicode"",
            candidateId : 2,
            description: unicode""
        });
        for (uint256 i = 0; i < candidates_.length; i++) {
            candidate[candidates_[i].candidateId] = candidates_[i];
            candidates.push(candidates_[i]);
        }
        

    }
    //Candidate[]  candidates_ = new Candidate[](1);
    // Стуктура для хранения списка голосующих с маппингов для уникальности
    struct Set {
        Voter[] values;
        mapping (address => bool) is_in;
    }

    // Инциаилизация списка голосующих 
    Set  voters_set;

    // Функция, добавляющая пользователей в список голосующих
    function addVoter() public isVotingEntryOpen() {
        if (!voters_set.is_in[msg.sender]) {
            Voter memory newvoter = Voter(payable(msg.sender),uint256(0));
            voters_set.values.push(newvoter);
            voters_set.is_in[msg.sender] = true;
        }
    }
    // Функция выводит список людей, записавшихся на голосование
    function getSeeVoters() view public returns (Voter[] memory myset_){
        myset_ = voters_set.values;  }

        modifier isVotingEntryOpen() {
        uint256 currentTime_ = block.timestamp;
        require(currentTime_ >= entryStartTime);
        require(currentTime_ <= entryEndTime);
        _;
    }


    // функция, позволяющая инициатору обновить время начала голосования
    function updateVtStartTime(uint256 startTime_)
        public isInitiator
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
        function vote(uint256 candidateId)
        public
        isVotingProcessOpen()
        isVoterEligible()
        haveVoted() returns (uint256 message)
    {
        voter[msg.sender].votedTo = candidateId;
        uint256 voteCount_ = votesCount[candidateId];
        votesCount[candidateId] = voteCount_ + 1;
        message = candidateId;
    }
    // модификатор проверяет, голосовал ли пользователь
    modifier haveVoted(){
        require(voter[msg.sender].votedTo == 0);
        _;
    }

    // модификатор проверяет, закончилось ли голосование
    modifier voteEnded(){
        uint256 currentTime_ = block.timestamp;
        require(votingEndTime < currentTime_);
        _;
    }
        // Модификатор проверяет, находится ли подписант сообщения в списке голосующих
    modifier isVoterEligible() {
        require(voters_set.is_in[msg.sender]);
        _;
    }
    // Модификатор проверяет, доступно ли голосование на момент подписания сообщения
        modifier isVotingProcessOpen() {
        uint256 currentTime_ = block.timestamp;
        require(currentTime_ >= votingStartTime);
        require(currentTime_ <= votingEndTime);
        _;
    }
    // Модификатор проверяет, является ли подписант сообщения инициатором голосования
    modifier isInitiator() {
        require(msg.sender == electionInitiator);
        _;
    }
    // function showMyVote(){

    // }
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

}