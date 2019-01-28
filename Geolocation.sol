pragma solidity ^0.5.2;

contract Geolocation {

    address private creator;
    enum Category {None, Hospital, Gym, Pharmacy}

    uint256 public numberOfParticipants = 0;
    mapping (address => uint256) addressToParticipantID;
    mapping (uint256 => bool) public sharingEnabled;
    mapping (uint256 => mapping(uint256 => bytes32)) participantCoordinates; 
    mapping (uint256 => uint256[]) participantDateTimes;
    mapping (uint8 => bytes32[]) categoryToLocation;
    mapping (bytes32 => Category) locationToCategory;

    constructor() public payable {
        creator = msg.sender;
    }
    
    
    /************************
    // Participant Post Methods
    ************************/

    function postParticipantLocation(uint256 _dateTime, int256 _lat, int256 _long) public {
        bytes32 curLoc = keccak256(abi.encodePacked(_lat, _long));
        // Check if user is new
        if (addressToParticipantID[msg.sender] == 0) {
            numberOfParticipants ++;
            addressToParticipantID[msg.sender] = numberOfParticipants;
            sharingEnabled[numberOfParticipants] = true;
        }
        uint256 participantID = addressToParticipantID[msg.sender];
        participantCoordinates[participantID][_dateTime] = curLoc;
        participantDateTimes[participantID].push(_dateTime);
    }
    
    function postParticipantSharingPreference() public {
        require(addressToParticipantID[msg.sender] != 0); // Require that participant exists
        uint256 participantID = addressToParticipantID[msg.sender];
        sharingEnabled[participantID] = !sharingEnabled[participantID];
    }
    

    
    /************************
    // Participant Get Methods
    ************************/
  
   function getParticipantID() public view returns (uint256) {
        require(addressToParticipantID[msg.sender] != 0); // Require that user exists
        return addressToParticipantID[msg.sender];
   }
   
    function getParticipantSharingStatus() public view returns (bool) {
        require(addressToParticipantID[msg.sender] != 0); // Require that participant exists
        uint256 participantID = addressToParticipantID[msg.sender];
        return sharingEnabled[participantID];
    }
    
    function getParticipantNumberOfLocations() public view returns (uint256) {
        uint256 participantID = addressToParticipantID[msg.sender];
        return participantDateTimes[participantID].length;
    }
    
    function getParticipantDateTimeOfLocation(uint256 _index) public view returns (uint256) {
        uint256 participantID = addressToParticipantID[msg.sender];
        return participantDateTimes[participantID][_index];
    }
    
    function getParticipantCategory(uint256 _dateTime) public view returns (Category) {
        uint256 participantID = addressToParticipantID[msg.sender];
        return locationToCategory[participantCoordinates[participantID][_dateTime]];
    }

    
    
    /************************
    // Third Party Post Methods
    ************************/
    
    function postPOI(Category _POIname, uint256 _lat, uint256 _long) public {
        bytes32 curLoc = keccak256(abi.encodePacked(_lat, _long));
        if (_POIname == Category.Hospital)  categoryToLocation[1].push(curLoc);
        if (_POIname == Category.Gym)       categoryToLocation[2].push(curLoc);
        if (_POIname == Category.Pharmacy)  categoryToLocation[3].push(curLoc);
        locationToCategory[curLoc] = _POIname;
    }
    
    
    /************************
    // Third Party Get Methods
    ************************/
    function getSharingEnabled(uint256 _participantID) public view returns (bool) {
        return sharingEnabled[_participantID];
    }
    
    function getNumberOfLocations(uint256 _participantID) public view returns (uint256) {
        require(sharingEnabled[_participantID]); // Require that participant has allowed sharing
        return participantDateTimes[_participantID].length;
    }
    
    function getDateTimeOfLocation(uint256 _participantID, uint256 _index) public view returns (uint256) {
        require(sharingEnabled[_participantID]); // Require that participant has allowed sharing
        return participantDateTimes[_participantID][_index];
    }
    
    function getCategory(uint256 _participantID, uint256 _dateTime) public view returns (Category) {
        require(sharingEnabled[_participantID]); // Require that participant has allowed sharing
        return locationToCategory[participantCoordinates[_participantID][_dateTime]];
    }

}

