// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    enum Move {Rock, Paper, Scissors }
    
    struct Game {
        Move playerMove;
        Move botMove;
        bool resolved;
        uint256 reward;
    }
    
    mapping(address => Game[]) public gameHistory;
    uint256 public betAmount = 0.0001 ether;
    
    event GameResult(address indexed player, Move playerMove, Move botMove, bool won, uint256 reward);
    
    function play(uint8 move) public payable {
        require(move >= uint8(Move.Rock) && move <= uint8(Move.Scissors), "Invalid move");
        require(msg.value == betAmount, "Incorrect bet amount");
        
        Move playerMove = Move(move);
        Move botMove = Move.Rock;
        
        bool won = determineWinner(playerMove, botMove);
        
        uint256 reward = calculateReward(won);
        
        Game memory newGame = Game({
            playerMove: playerMove,
            botMove: botMove,
            resolved: true,
            reward: reward
        });
        
        gameHistory[msg.sender].push(newGame);
        
        emit GameResult(msg.sender, playerMove, botMove, won, reward);
        
        if (won) {
            // Transfer the reward to the player
            (bool success, ) = payable(msg.sender).call{value: reward}("");
            require(success, "Reward transfer failed");
        }
    }
    
    function generateBotMove() internal view returns (Move) {
        uint8 random = uint8(block.timestamp) % 3 + 1;
        return Move(random);
    }
    
    function determineWinner(Move playerMove, Move botMove) internal pure returns (bool) {
        if (playerMove == botMove) {
            return false; // It's a draw
        }
        if (
            (playerMove == Move.Rock && botMove == Move.Scissors) ||
            (playerMove == Move.Paper && botMove == Move.Rock) ||
            (playerMove == Move.Scissors && botMove == Move.Paper)
        ) {
            return true; // Player wins
        }
        return false; // Bot wins
    }
    
    function calculateReward(bool won) internal view returns (uint256) {
        if (won) {
            return betAmount * 2;
        } else {
            return 0;
        }
    }
    
    function getGameCount(address player) public view returns (uint256) {
        return gameHistory[player].length;
    }
}
