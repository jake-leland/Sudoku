// Jake Leland

/* SUDOKU SOLVER
 * 
 * This program reads in a file called puzzle.txt,
 * makes a graphical representation of the puzzle,
 * and then sytematically solves it, showing the
 * step-by-step elimination process.
 * 
 * Click the mouse or press a key to complete a step.
 */

int[][] puzzle;
String[] lines;
ArrayList<Integer>[][] notes;
String puzzleString;
boolean possibilitiesUpdated;
boolean error;
boolean finished;
int stepCount;

void setup()
{
  size(704, 704);
  possibilitiesUpdated = false;
  stepCount = 0;
  importPuzzle("puzzle.txt");
}

void draw()
{
  displayPuzzle();
}

void mousePressed()
{
  step();
}

void keyPressed()
{
  step();
}

void step()
{
  if (!finished)
  {
    if (!possibilitiesUpdated)
      updatePossibilities();
    else
      checkForLonePossibilities();
    checkError();
    checkFinished();
  }
}

// Load the puzzle file into an array
void importPuzzle(String fileName)
{
  puzzle = new int[9][9];
  lines = loadStrings(fileName);
  for (int r=0; r<9; r++)
  {
    for (int c=0; c<9; c++)
    {
      char num = lines[r].charAt(c);
      if (num == ' ')
        puzzle[r][c] = -1;
      else
        puzzle[r][c] = Integer.parseInt(""+num);
    }
  }

  notes = new ArrayList[9][9];
  for (int r=0; r<9; r++)
  {
    for (int c=0; c<9; c++)
    {
      notes[r][c] = new ArrayList<Integer>();
    }
  }
}

// Load the puzzle array into a string
void loadPuzzleString()
{
  puzzleString = "";
  for (int r=0; r<9; r++)
  {
    for (int c=0; c<9; c++)
    {
      puzzleString+=puzzle[r][c] + " ";
    }
    puzzleString+="\n";
  }
}

// Draw the puzzle on screen
void displayPuzzle()
{
  if (error)
    background(255, 0, 0);
  else if (finished)
    background(0, 255, 0);
  else
    background(200);

  text("Steps: " + stepCount, width/2, height-32);

  //grid
  strokeWeight(3);
  fill(255);
  rect(64, 64, 576, 576);
  for (int i=0; i<8; i++)
  {
    if ((i+1)%3==0)
      strokeWeight(3);
    else
      strokeWeight(1);
    line(64, (i+2)*64, 640, (i+2)*64);
    line((i+2)*64, 64, (i+2)*64, 640);
  }

  //numbers
  textAlign(CENTER, CENTER);
  fill(0);
  for (int r=0; r<9; r++)
  {
    for (int c=0; c<9; c++)
    {
      int num = puzzle[r][c];
      if (num > 0)
      {
        //display number
        textSize(48);
        fill(0);
        text(num, ((r+1)*64)+32, ((c+1)*64)+28);
      }
      else
      {
        //display notes
        textSize(16);
        fill(100);
        for (int nR=0; nR<3; nR++)
        {
          for (int nC=0; nC<3; nC++)
          {
            if (notes[r][c].contains(nR+(3*nC)+1))
              text(nR+(3*nC)+1, ((r+1)*64)+((nR+1)*16), ((c+1)*64)+((nC+1)*16));
          }
        }
      }
    }
  }
}

// Look at all of the other numbers in the row, column, and block
// If there is a number that does not occur in any of
// these three situations, it is a possibility.
void updatePossibilities()
{
  for (int r=0; r<9; r++)
  {
    for (int c=0; c<9; c++)
    {
      for (int i=1; i<=9; i++)
      {
        if (!rowContains(r, i) && !colContains(c, i) && !blockContains(r, c, i))
        {
          if (puzzle[r][c]<0 && !notes[r][c].contains(i))
            notes[r][c].add(i);
        }
        else
        {
          if (notes[r][c].contains(i))
            notes[r][c].remove(new Integer(i));
        }
      }
    }
  }
  possibilitiesUpdated = true;
}

// Check to see if the given row contains the given number.
boolean rowContains(int r, int i)
{
  for (int c=0; c<9; c++)
  {
    if (puzzle[r][c]==i)
      return true;
  }
  return false;
}

// Check to see if the given column contains the given number.
boolean colContains(int c, int i)
{
  for (int r=0; r<9; r++)
  {
    if (puzzle[r][c]==i)
      return true;
  }
  return false;
}

// Check to see if the given block contains the given number.
// Note: this method accepts a row and a column, and automatically
// figures out what block that spot is in.
boolean blockContains(int rIn, int cIn, int i)
{
  for (int r=0; r<3; r++)
  {
    for (int c=0; c<3; c++)
    {    
      if (puzzle[r + (rIn/3*3)][c + (cIn/3*3)]==i)
        return true;
    }
  }
  return false;
}

// Check to see if any space has only one possibility.
// If there is only one possibility, it is the answer to that space.
void checkForLonePossibilities()
{
  stepCount++;
  for (int r=0; r<9; r++)
  {
    for (int c=0; c<9; c++)
    {
      if (notes[r][c].size()==1)
        puzzle[r][c] = notes[r][c].remove(0);
    }
  }
  possibilitiesUpdated = false;
}

// Hasn't been coded yet.
// I intended for this to check for errors along the way.
// This is not the same as doubleCheckError(), which checks
// at the end of the whole process.
void checkError()
{
  return;
}

// If all of the spaces have been filled with answers,
// the puzzle is complete.
void checkFinished()
{
  for (int r=0; r<9; r++)
  {
    for (int c=0; c<9; c++)
    {
      if (puzzle[r][c]<0)
      {
        finished = false;
        return;
      }
    }
  }
  doubleCheckError();
  finished = true;
}

// This method is called after the puzzle is complete.
// It checks to see if there are duplicate numbers in any
// of the rows, columns, or blocks.
// The puzzle will not be considered complete if there is an error.
void doubleCheckError()
{
  for (int i=0; i<9; i++)
  {
    for (int j=1; j<10; j++)
    {
      if (!rowContains(i, j) || !colContains(i, j))
      {
        error = true;
        return;
      }
      if (i%3 == 0)
      if (!blockContains(i, i, j))
      {
        error = true;
        return;
      }
    }
  }
  error = false;
}
