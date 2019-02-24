pragma solidity ^0.5.0;
//import "github.com/Arachnid/solidity-stringutils/strings.sol";
import './WRCToken.sol';
pragma experimental ABIEncoderV2;
contract WRC
{
//  using strings for *;
//using WRCToken for *;

uint  _presPhLevel;
uint  _presAvgSuspendedSolids;
uint _presAvgHardness;
uint  _presAvgOilAndGrease;
uint _presSetBOD;
uint _presSetReusePercentage ;

uint  actualPhLevel;
uint  actualAvgSuspendedSolids;
uint actualAvgHardness;
uint  actualAvgOilAndGrease;
uint actualSetBOD;
uint actualSetReusePercentage ;
       struct Entity
       {
           string entityId;
           string name;
           string entityAddr;
           string entityType; // type of entity ie society, industry
           string[] recyclingPlants;
           address[] inletMeterIds; // inlet meter id
           address[] outletMeterIds; // outlet meter id
        }
        Entity[] public entities;


        mapping(uint => Entity) EntityMap;  //*

        uint entityCount;

        struct SetTarget{
          uint entityType;
          uint setAvgPHLevel;
          uint setAvgSuspendedSolids; // in mg/l
          uint setAvgHardness;
          uint setAvgOilAndGrease; // in mg/l
          uint setBOD; // in mg/l
          uint setReusePercentage; // in %
        }
        SetTarget[] public targets; // will be called only by the owner
        //mapping(string => SetTarget) public EntityTypeToTargets;
        //mapping(string => struct) Targets; // fetch

        struct InletMeterRecord
        {
          string entityId;
          address inletMeterId;  //public key of the address.
        //  string inletMeterType; //The type of meter used. (Water / Electricity etc)
          uint inletLiquid; //volume of water measured in last hour.
          string InletPlantID;
          uint timeStamp;
        }
        InletMeterRecord[] storeInletWater; //dynamic array which will store the water.

        struct reading
        { // the reading will come from the IoT meter and will be fed to the blockchain via UI.
            address meterId;
            string entityId;
            string plantID; //The ID of the recycling plant where the meter is installed. This is used as a single organisation is expected to have multiple plants
			      uint outletLiquid; //m3/hour - volume of water measured in last hour
            uint avgPHLevel;
            uint avgSuspendedSolids; // in mg/l
            uint avgHardness;
            uint avgOilAndGrease; // in mg/l
            uint BOD; // in mg/l
            uint timeStamp; //The time in milliseconds since epoch when this data block was reported
        }
       reading[] storeOutletWater; //dynamic array which will store the water.

       mapping(address => string) public MeterPlantMapping; // for both inlet and outlet meter.

       mapping(address => string) public MeterToEntity; // will store the entity id.

       mapping(string => address) private EntityToMeter; //will be used to fetch the meters by passing EntityId as a key.

      //   mapping(address => string) public MeterToPlant; //for both inlet and outlet meter.


      function RegisterEntity(string memory _ename,string memory _addr,string memory _entityType,
        string[]  memory _plants, address[] memory _inletIds,address[] memory _outletIds) public
      {
            //string memory _eId = "fdfdfdf" ; //keccak256(abi.encodePacked(_ename)) ; //uint(keccak256(abi.encodePacked(_ename)));
            string memory _eId = uint2str(uint(keccak256(abi.encodePacked(_ename))));

            entities.push(Entity(_eId,_ename,_addr,_entityType,_plants,_inletIds,_outletIds ));
      }

      function uint2str(uint _i) internal pure returns (string memory _uintAsString)
      {
            if (_i == 0) {
                return "0";
            }
            uint j = _i;
            uint len;
            while (j != 0) {
                len++;
                j /= 10;
            }
            bytes memory bstr = new bytes(len);
            uint k = len - 1;
            while (_i != 0) {
                bstr[k--] = byte(uint8(48 + _i % 10));
                _i /= 10;
            }
            return string(bstr);
      }


    function FetchSetStandards(string memory _eType) public view returns(uint,uint,uint,uint,uint,uint)
    {
      for(uint j=0; j< targets.length; j++)
      {
        if(uint(keccak256(abi.encodePacked(targets[j].entityType))) == uint(keccak256(abi.encodePacked(_eType))))
        {
           return(targets[j].setAvgPHLevel,targets[j].setAvgSuspendedSolids,targets[j].setAvgHardness,targets[j].setAvgOilAndGrease,targets[j].setBOD,targets[j].setReusePercentage);
        }
      }

    }

     function FetchEntityType(string memory _eId) public view returns(string memory) //onlyOwner
     {
       for(uint i=0;i<entities.length;i++)
       {

           if(uint(keccak256(abi.encodePacked(entities[i].entityId))) == uint(keccak256(abi.encodePacked(_eId))))
           {
            return entities[i].entityType;
           }
       }

     }

     function FetchEntityId(string memory _entityName) public view returns(string memory)
     {
       string memory _entityId;
       for(uint i=0;i<entities.length;i++)
       {
           //if(entities[i].name== "entityName")
           if(uint(keccak256(abi.encodePacked(entities[i].name))) == uint(keccak256(abi.encodePacked(_entityName))))
           {
             _entityId=entities[i].entityId;
             break;
           }
       }
       return _entityId;
     }

     function FetchWaterPerMeter(string memory _entityID,string memory _inletOrOutlet) public returns(uint)
     {
       string[] memory _inletIds;
       uint _currentTIme = now;
       uint  _waterVolume;

      if(uint(keccak256(abi.encodePacked(_inletOrOutlet))) == uint(keccak256(abi.encodePacked("inlet"))))
      {
       for(uint i=0; i<storeInletWater.length; i++)
       {
         if(uint(keccak256(abi.encodePacked(storeInletWater[i].entityId))) == uint(keccak256(abi.encodePacked(_entityID))))
         {
            // _totalSuppliedWater = _totalSuppliedWater + storeInletWater[i].inletLiquid ;
            if(_currentTIme <= storeInletWater[i].timeStamp + 10080 minutes) // 1 week =10080 minutes
            {
                _waterVolume = _waterVolume + storeInletWater[i].inletLiquid;

            }
         }
       }
     }

     else if(uint(keccak256(abi.encodePacked(_inletOrOutlet))) == uint(keccak256(abi.encodePacked("outlet"))))
       {
         // string memory _presPhLevel;
         // string memory _presAvgSuspendedSolids;
         // string memory _presAvgHardness;
         // string memory _presAvgOilAndGrease;
         // string memory _presSetBOD;
         // string memory _presSetReusePercentage ;
         bool _hasMetStandards=false;
        for(uint i=0; i<storeOutletWater.length; i++)
        {
          if(uint(keccak256(abi.encodePacked(storeOutletWater[i].entityId))) == uint(keccak256(abi.encodePacked(_entityID))))
          {
             // _totalSuppliedWater = _totalSuppliedWater + storeInletWater[i].inletLiquid ;
             if(_currentTIme <= storeOutletWater[i].timeStamp + 10080 minutes) // 1 week =10080 minutes
             {
                 _waterVolume = _waterVolume + storeOutletWater[i].outletLiquid;
             }
          }
        }
      }
       return _waterVolume;
     }

     function FetchWaterComponentsAmt(string memory _entityID) public returns(uint,uint,uint,uint,uint) //onlyowner
     {
       // string memory _presPhLevel;
       // string memory _presAvgSuspendedSolids;
       // string memory _presAvgHardness;
       // string memory _presAvgOilAndGrease;
       // string memory _presSetBOD;
       uint _currentTIme= now;
       for(uint i=0; i<storeOutletWater.length; i++)
       {
         if(uint(keccak256(abi.encodePacked(storeOutletWater[i].entityId))) == uint(keccak256(abi.encodePacked(_entityID))))
          {
            if(_currentTIme <= storeOutletWater[i].timeStamp + 10080 minutes) // 1 week =10080 minutes
            {
              return (storeOutletWater[i].avgPHLevel,
                storeOutletWater[i].avgSuspendedSolids,
                storeOutletWater[i].avgHardness,
                storeOutletWater[i].avgOilAndGrease,
                storeOutletWater[i].BOD);
            }
          }
       }
     }


     function VerifyStandards(string memory entityName) public //onlyOwner
      {
        //fetch inlet water consumed.

        uint _inletWater =  FetchWaterPerMeter(FetchEntityId(entityName),"inlet");
        uint _outletWater = FetchWaterPerMeter(FetchEntityId(entityName),"outlet");
        // fetch inlet and outlet meter
        (_presPhLevel, _presAvgSuspendedSolids,_presAvgHardness,_presAvgOilAndGrease,_presSetBOD,_presSetReusePercentage) = FetchSetStandards(FetchEntityType(FetchEntityId(entityName)));
        // uint  actualPhLevel;
        // uint  actualAvgSuspendedSolids;
        // uint actualAvgHardness;
        // uint  actualAvgOilAndGrease;
        // uint actualSetBOD;
        // uint actualSetReusePercentage ;
        (actualPhLevel, actualAvgSuspendedSolids,actualAvgHardness,actualAvgOilAndGrease,actualSetBOD) =  FetchWaterComponentsAmt(FetchEntityId(entityName));

         uint _percReUse =  (_outletWater/ _inletWater) * 100;

         if(_percReUse >= _presSetReusePercentage )
         {
           if(actualPhLevel <= _presPhLevel && actualAvgSuspendedSolids <= _presAvgSuspendedSolids && actualAvgHardness <= _presAvgHardness
           && actualAvgOilAndGrease <= _presAvgOilAndGrease && actualSetBOD <= _presSetBOD)
           {
             // code to transfer token.
           }
         }
      }

}  // end of contract
