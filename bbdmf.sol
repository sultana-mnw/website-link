pragma solidity ^0.4.18;

import "./FundToken.sol";


contract DMF {
    
        FundToken public Token; //obj for Fundtoken
    
        //modifier only access the functions by Portfolio manager 
        modifier OnlyPortfolio()
        {
            if(msg.sender == portfolioMAdd[0])
            {
                _;
            }
            revert();
        }
        //Global Variable Declaration part

        address owner; //owner variable for assigning contract Owner
        address public newadd; //For getting the Contract Address
        uint256 rate = 0.001 ether; //rate of Fundtoken For PortfolioManager
        uint256 cost = 0.01 ether;  //rate of FundToken For Investors
        uint256 dividendTK = 100; //divident tokens count for give the profit to Investor
        uint256 profitTk = 10; //profit tokens for the Portfolio manager 
        uint256 public total = 0; 
        uint256 public pprofit = 0; //For the Portfoliomanager profit tokens 
        address contractAddress; //Fundtoken
        
    //ArrayList
     address[] portfolioMAdd; //Array for storing the each register PortfolioManager
     address[] public Investor; //Array for storing the each register Investors
   
    //Phase -2
                            //Structure Area


     //Structure For PortfolioManager Details
            struct PortfolioMFTK
            {
                address portfolioM;
                //address contractAdd;
                uint256 Eth;
            }
    //Structure For Investor Details  
            struct InvestorPTk
            {
                address buyer;
                uint256 Eth;
                uint256 howTK;
            }

    //Constructor For initialize the contract Owner Address and Contract Deployed Address
            function DMF(address na)public{
                owner=msg.sender;
                newadd=address(this);
                Token=new FundToken();
                 contractAddress=na;
                
            }
       
           
                             //Mapping Area

      mapping(address => PortfolioMFTK) public BuyTK; //Map for getting and storing the PortfolioManager resgistration Details
      mapping(address => InvestorPTk) public BuyInves; //map for getting and storing the Investor getting token details
      //Fallback Function For Holding the Ether in Contract
      function () public payable{
          
      }
      

                                //Function Area
        //Function For PortfolioManager Resgistration
        function PortfolioReg() public payable{
            BuyTK[msg.sender].portfolioM= msg.sender;
            BuyTK[msg.sender].Eth=BuyTK[msg.sender].Eth + msg.value;
         
            GetFundToken(msg.value);
        }
        
       

        //Function For Getting the Fundtokens by the PortfolioManager
         function GetFundToken(uint256 value) private{
            uint256 tokens = value / rate;
            FundToken(contractAddress).updateD(msg.sender,tokens);
            //Transfer(0,msg.sender,msg.value);
           
           
            portfolioMAdd.push(msg.sender);
         }

        //Function For Getting the Contract Ether Balance 
      function GetBal()public view returns(uint256){
          return this.balance/ 1 ether; //converting wei value to ether
      }
      

      //Function For Getting the Contract Address
      function getContractaddress() public view returns(address)
      {
          return newadd;
      }
      
      
      //Phase-3

      //Function For Buying the FundTokens by the Investor From the PortfolioManager
      function getTokens() public payable
      {
          uint256 tokens = msg.value / cost;
          FundToken(contractAddress).updateD(msg.sender,tokens);
          FundToken(contractAddress).dDetails(portfolioMAdd[0],tokens);
          portfolioMAdd[0].transfer(msg.value);
          Investor.push(msg.sender);
          BuyInves[msg.sender].buyer = msg.sender;
          BuyInves[msg.sender].Eth = msg.value;
          BuyInves[msg.sender].howTK = tokens;
          
      }
    
  

    //Phase-4


    //Function For Getting the Investor Balance of Tokens
    function getBalance() public view returns(uint256)
    {
       return  FundToken(contractAddress).gettheD(Investor[0]);
    }

    //Phase-5
    
    /** The dividends calculations
        Investor1 = (( Investor1_fund TK) / (Inves1_FUndTK + Inves2_FUndTK + ... )) * 90;
     */
    //Function For issue the Dividends yo the User
    function Dividends() public OnlyPortfolio  returns(uint256)  
    {
        
        FundToken(contractAddress).dDetails(owner,dividendTK); //minting the token 
        pprofit = (dividendTK * 10) / 100; //taking the portfolio share
        FundToken(contractAddress).updateD(msg.sender,pprofit);
        for(uint256 i =0;i < Investor.length; i++)
        {
          total +=  BuyInves[Investor[i]].howTK;
        }
        
         ShareETK_ToI();
         
         
    }
    
    
    
    //function for split the profit to each tokens
    function ShareETK_ToI() private 
    {
        for(uint256 i=0;i<Investor.length;i++)
        {
            uint256 b = BuyInves[Investor[i]].howTK * (dividendTK - pprofit);
             uint256 a =  b  / total;
           FundToken(contractAddress).updateD(Investor[i],a);
        }
    }
    
    
    //getting All the Investor and PortfolioManager balance 
    function getAllBalance() public view returns(uint256)
    {
     return FundToken(contractAddress).gettheD(msg.sender);
    }
    

   
}