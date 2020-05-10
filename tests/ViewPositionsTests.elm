module ViewPositionsTests exposing (..)


import Expect exposing (Expectation)
import Test exposing (..)
import Model exposing (..)
import Array exposing (Array)
import Dict exposing (Dict)

import TestModel
import ViewPositions
import ViewVariables exposing (functionXSpacing, blockSpace, lineSpaceBeforeBlock)

myexpect item1 item2 =
    (\_ ->
         (Expect.equal item1 item2))

outputConnectedArrayTest func expected =
    let
        svgScreenWidth = 1000
        svgScreenHeight = 1000
        mouseState = (MouseState 0 0 NoneSelected)
        blockPositions = (ViewPositions.getBlockPositions func mouseState svgScreenWidth svgScreenHeight 0 0)
        madePos = ViewPositions.makeIdToPos func blockPositions
        sortedFunc = (Tuple.first madePos)
        idToPos = (Tuple.second madePos)
        connectedArray = ViewPositions.getOutputConnectedArray sortedFunc idToPos
    in
        (myexpect
             connectedArray
             (Tuple.mapBoth Array.fromList Array.fromList expected))
        
fixInvalidInputs : Test
fixInvalidInputs =
    describe "getOutputConnectedArray"
        [test "no connections"
             (outputConnectedArrayTest TestModel.testFunctionHoles
                  ([0,0,0,0]
                  ,[0,0,0,0]))
        ,test "test connections"
            (outputConnectedArrayTest TestModel.testFunction
                  ([1, 0, 1, 0]
                  ,[0, 1, 0, 0]))
        ,test "test complex"
            (outputConnectedArrayTest TestModel.complexRoutingFunc
                 ([1, 1, 0, 0, 0]
                 ,[1, 1, 0, 1, 0]))
        ]
                

blockPositionToTuple blockPos =
    (blockPos.xpos, blockPos.ypos)
        
callBlockPositions testFunc mouse =
    Result.map (List.map blockPositionToTuple)
        (ViewPositions.blockPositionsToPositionList testFunc
             (ViewPositions.getViewStructure testFunc
                  mouse ViewVariables.viewportWidth ViewVariables.viewportWidth 0 0 False).blockPositions)

            
emptyMouse = (MouseState 0 0 NoneSelected)

secondToLastMouse = (MouseState (ViewVariables.blockWidth//2)
                         (blockSpace+2*lineSpaceBeforeBlock+ViewVariables.svgYpos+(ViewVariables.blockHeight//2))
                         (BlockSelected 23))
                    
blockPositionsTest : Test
blockPositionsTest =
    describe "getBlockPositions"
        [test "test func"
             (myexpect
                  (callBlockPositions TestModel.testFunction emptyMouse)
                  (Ok [(0, 0)
                      ,(0, blockSpace)
                      ,(0, blockSpace*2 + 2*lineSpaceBeforeBlock)
                      ,(0, blockSpace*3 + (1+2)*lineSpaceBeforeBlock)]))
        ,test "complex connections"
             (myexpect
                  (callBlockPositions TestModel.complexRoutingFunc emptyMouse)
                  (Ok [(0, 0)
                      ,(0, blockSpace + lineSpaceBeforeBlock)
                      ,(0, blockSpace*2 + (1+1)*lineSpaceBeforeBlock)
                      ,(0, blockSpace*3 + (1+1+2)*lineSpaceBeforeBlock)
                      ,(0, blockSpace*4 + (1+1+2+2)*lineSpaceBeforeBlock)]))
        ,test "move block two up"
             (myexpect
                  (callBlockPositions TestModel.complexRoutingFunc
                       secondToLastMouse)
                  (Ok [(0, 0)
                      ,(0, blockSpace*2 + (1+2)*lineSpaceBeforeBlock)
                      ,(0, blockSpace*3 + (1+2+1)*lineSpaceBeforeBlock)
                      ,(0, blockSpace + 2*lineSpaceBeforeBlock)
                      ,(0, blockSpace*4 + (1+1+2+2)*lineSpaceBeforeBlock)]))]


movedInfoTest : Test
movedInfoTest =
    describe "getMovedInfo"
        [test "test select second to last"
             (myexpect
                  (ViewPositions.getMovedInfo TestModel.complexRoutingFunc secondToLastMouse
                       (ViewPositions.mouseToSvgCoordinates secondToLastMouse ViewVariables.viewportWidth ViewVariables.viewportWidth 0 0))
                  (Just (ViewPositions.MovedBlockInfo TestModel.secondToLastSine
                             (0, blockSpace + 2*lineSpaceBeforeBlock))))
                                       
               ]
