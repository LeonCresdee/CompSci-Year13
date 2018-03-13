
class GUI {
  float x, y;
  float Width, Height;
  String ID;
  color Color;
  GUI parent = null;
  
  boolean WithinBounds(float X, float Y){
    if (this instanceof Node ){
      Node node = (Node)this;
      X = node.canvas.screenToCanvas(X, Y)[0];
      Y = node.canvas.screenToCanvas(X, Y)[1];
    }
    //Since plugs are circular its easier just to find the distance to their center
    if (this instanceof plug){
      plug Plug = (plug)this;
      if (distance(new float[]{Plug.x+Plug.node.x, Plug.y+Plug.node.y}, Plug.node.canvas.screenToCanvas(X, Y)) < (Plug.Width/2)/Plug.canvas.scale){
        return true;
      }else{
        return false;
      }
    }
    

    if (X >= getX() && Y >= getY()){
      if (X <= getX() + getWidth() && Y <= getY() + getHeight()){
        
        return true;
      } else {return false;}
    } else {return false;}
  }
  
  float getX(){
    float X = 0;
    if (parent instanceof Node){
      Node Parent = (Node)parent;
      X += Parent.canvas.canvasToScreen(X + Parent.x, 0)[0];
      X += x * Parent.canvas.scale;
    } else{
      X += x;
    }
    return X;
  }
  
  float getY(){
    float Y = 0;
    if (parent instanceof Node){
      Node Parent = (Node)parent;
      Y += Parent.canvas.canvasToScreen(0, Y + Parent.y)[1] + Parent.headsize*Parent.canvas.scale/2;
      Y += y * Parent.canvas.scale;
    } else{
      Y += y;    
    }
    return Y;
  }
  
  float getWidth(){
    float scaledWidth = Width;
    if (parent instanceof Node){
      Node Parent = (Node)parent;
      scaledWidth *= Parent.canvas.scale;
    }
    return scaledWidth;
  }
  
  float getHeight(){
    float scaledHeight = Height;
    if (parent instanceof Node){
      Node Parent = (Node)parent;
      scaledHeight *= Parent.canvas.scale;
    }
    return scaledHeight;
  }
  
  void update(){return;}
  void hover(){return;}
  void pressed(){return;}
  void released(){return;}
  void deactivate(){return;}
  void dragRelease(){return;}
  void mouseDown(){return;}
}


ArrayList<GUI> Elements = new ArrayList<GUI>();
GUI[] FindByID(String ID){
  ArrayList<GUI> matchingElements = new ArrayList<GUI>();
  for (int i = 0; i < Elements.size(); i++){
    if (Elements.get(i).ID == ID){
      matchingElements.add(Elements.get(i));
    }
  }
  return matchingElements.toArray(new GUI[0]);
}

class Button extends GUI{
    color TextColor = color(255), HighlightColor = color(180), TextHighlightColor = color(50), PressColor = color(210), TextPressColor = color(0);
    String Text = "";
    public boolean Highlight = false, Pressed = false;
    float FontSize = 48;
    Button(float x, float y, float Width, float Height, color Color){
      this.x = x;
      this.y = y;
      this.Width = Width;
      this.Height = Height;
      this.Color = Color;
    }
    
    void released(){
      onPress();
    }
    
    void pressed(){
      Pressed = true;
      Highlight = false;
    }
    
    void hover(){
      Pressed = false;
      Highlight = true;
    }
    
    void onPress(){
    }
    void update(){
      //Rect
      if (Highlight){
        stroke(color(red(Color)/10, blue(Color)/10, green(Color)/10));
        fill(HighlightColor);
      }else if (Pressed){
        stroke(color(red(Color)/10, blue(Color)/10, green(Color)/10));
        fill(PressColor);
      }else{
        stroke(color(red(Color)/10, blue(Color)/10, green(Color)/10));
        fill(Color);
      }
      rect(getX(), getY(), getWidth(), getHeight());
      //Text
      if (Highlight){
        fill(TextHighlightColor);
      }else if(Pressed){
        fill(TextPressColor);
      }else{
        fill(TextColor);
      }
      textAlign(CENTER);
      textSize(FontSize);
      text(Text, getX()+(getWidth()/2), getY()+(getHeight()/2)+10);
      Highlight = false;
      Pressed = false;
      if (parent instanceof Node){
      }
    }
}

class TextInput extends GUI{
  color TextColor = color(255);
  String value = "";
  boolean active = false;
  float FontSize = 48;
  
  private boolean useSet = false;
  private String[] charset;
  
  private int textMode = 0;
  void setTextMode(String mode){
    switch(mode){
      case "PARAGRAPH": 
        //Draw text as a block paragraph
        textMode = 0;
        break;
      case "LINE":
        //Draw text as a single line
        textMode = 1;
        break;
      case "CENTER":
        //Draw text centered on the text box
        textMode = 2;
        break;
      default:
        throw new IllegalArgumentException(mode + " is an unknown Text Mode\n");
    }
  }
  
  boolean inSet(String Char){
    for (int i = 0; i < charset.length; i++){
      if (charset[i].charAt(0) == Char.charAt(0)){
        return true;
      }
    }
    return false;
  }
  
  void setCharacterSet(String[] set){
    useSet = true;
    charset = set;
  }
  
  void clearSet(){
    useSet = false;
    charset = null;
  }
  
  TextInput (float x, float y, float Width, float Height, color Color){
      this.x = x;
      this.y = y;
      this.Width = Width;
      this.Height = Height;
      this.Color = Color;
  }
  
  String getText(){
    return value;
  }
  
  void pressed(){
    active = true;
  }
  void deactivate(){
    active = false;
  }
  void update(){
    fill(Color);
    stroke(color(red(Color)/10, blue(Color)/10, green(Color)/10));
    rect(getX(), getY(), getWidth(), getHeight());
    int overflow = 0;
    while(textWidth(value.substring(overflow, value.length())) > getWidth()){
      overflow++;
    }  
    if(active){
      for(int i = 0; i < charBuffer.size(); i++){
        if (charBuffer.get(i) == "BACK" && value.length() > 0){
          value = value.substring(0, value.length()-1);
        }else if(charBuffer.get(i) != "BACK"){
          if (useSet){
            if (inSet(charBuffer.get(i))){
              value += charBuffer.get(i);
            }
          }else{
            value += charBuffer.get(i);
          }
            
        } 
      }
      fill(TextColor);
      textAlign(CORNER);
      String text = value.substring(overflow, value.length());
      if (second() % 2 == 0){
        text += "|";
      }
      switch (textMode){
        case 0:
          //paragraph
          text(text, getX(), getY() + FontSize/2);
          break;
        case 1:
          //line
          text(text, getX(), getY() + (getHeight()/2));
          break;
        case 2:
          //Center
          text(text, getX() + (getWidth()/2), getY() + (getHeight()/2));
          break;
      }

      
    }else{
      //draw without |
      fill(TextColor);
      textAlign(CORNER);
      text(value.substring(overflow, value.length()), getX(), getY() + (getHeight()/2));
    }
  }
  
  void drawText(boolean Active){
    if (Active){
      if (second() % 2 == 0){
        if (getTextMode() == 0){
          text(value.substring(overflow, value.length()), getX(), getY() + fontSize / 2);
        }
      } else{
        
      }
    }else{
    
    }
  }
  
  
}

class Label extends GUI{
  color TextColor = color(255);
  String text = "";
  float FontSize = 48;

  Label (float x, float y, float Width, float Height, color Color){
    this.x = x;
    this.y = y;
    this.Width = Width;
    this.Height = Height;
    this.Color = Color;
  }
  
  void update(){
    //Box
    fill(Color);
    stroke(color(red(Color)/10, blue(Color)/10, green(Color)/10));
    rect(getX(), getY(), getWidth(), getHeight());
    
    //Text
    fill(TextColor);
    textAlign(CENTER);
    textSize(FontSize);
    text(text, getX()+(getWidth()/2), getY()+(getHeight()/2)+10);

  }
}

class Toggle extends GUI{
  boolean active = false;
  color HighlightColor = #83F4FF;
  
  Toggle (float X, float Y, float Width, float Height, color Color){
    this.x = X;
    this.y = Y;
    this.Width = Width;
    this.Height = Height;
    this.Color = Color;
  }
  
  void update(){
    fill(color(100));
    stroke(HighlightColor);
    ellipse(getX()+(getWidth()/2), y+(getHeight()/2), getWidth(), getHeight());
    noStroke();
    if (active){
      fill(HighlightColor);
      ellipse(getX()+(getWidth()/2), getY()+(getHeight()/2), getWidth()*0.6, getHeight()*0.6);
    }else{
      fill(60);
      ellipse(getX()+(getWidth()/2), getY()+(getHeight()/2), getWidth()*0.6, getHeight()*0.6);
    }
  }
  
  void toggle(){}
  
  void released(){
    active = !active;
    toggle();
  }
}

class Dropdown extends GUI{
    int optionIndex = 0;
    color TextColor = color(100);
    color ButtonColor = color(100);
    boolean open = false;
    int options = 1;
    float OptionHeight;
    ArrayList<String> optionNames = new ArrayList<String>();
    
    Dropdown(float X, float Y, float Width, float Height, color Color){
      this.x = X;
      this.y = Y;
      this.Width = Width;
      this.Height = Height;
      this.Color = Color;
    }
    
    void update(){
      fill(Color);
      rect(getX(), getY(), getWidth()-getHeight(), getHeight());
      fill(TextColor);
      textAlign(CENTER);
      text(optionNames.get(optionIndex), getX() + ((getWidth()-getHeight())/2), getY() + getHeight()/2 + 10);
      fill(ButtonColor);
      rect(getX() + getWidth() - getHeight(), getY(), getHeight(), getHeight());
      fill(40);
      triangle(getX()+getWidth()-(getHeight()/2), getY()+getHeight() - 10, getX() + getWidth() - getHeight() + 10, getY() + 10, getX() + getWidth() - 10 , getY() + 10);      
    }
}

class Listbox extends GUI{
  ArrayList<String> options = new ArrayList<String>();
  color TextColor = color(230);
  int scrollAmount = 0;
  int optionsShowing;
  float optionHeights;
  float FontSize = 32;
  int highlightOption = -1;
  color highlightColor = color(100, 0, 200);
  color BlankColor = color(60);
  float padding = 5;
  Listbox(float X, float Y, float Width, color Color, float optionHeights, int optionsShowing){
    this.x = X;
    this.y = Y;
    this.Width = Width;
    this.Color = Color;
    this.optionHeights = optionHeights;
    this.optionsShowing = optionsShowing;
    this.Height = optionHeights * optionsShowing;
  }
  
  void scrollDown(){
    if(scrollAmount < (options.size() - optionsShowing)){
      scrollAmount++;
    }
  }
  
  void scrollUp(){
    if (scrollAmount >0){
      scrollAmount--;
    }
  }
  
  void released(){
    onPress();
  }
  
  void hover(){
    highlight(true);
  }
  
  void onPress(){
    returnSelected(getIndex());
  }
  int getIndex(){
    float index = ((mouseY - getY()) - (mouseY%optionHeights)) / optionHeights;
    int Index = round(index);
    if(Index > optionsShowing-1){Index = optionsShowing-1;}
    Index += scrollAmount;
    return Index;
  }
  
  void returnSelected(int index){
    //To be overriden on instance
  }
  
  void highlight(boolean highlight){
    if (highlight){
      highlightOption = getIndex() -scrollAmount;
    }else{
      highlightOption = -1;
    }
  }
  
  void update(){
    fill(Color);
    stroke(TextColor);
    rect(x, y, Width, optionsShowing*optionHeights);
    fill(highlightColor);
    if (highlightOption >= 0 && highlightOption < options.size()){
      rect(x, y+(optionHeights*highlightOption), Width, optionHeights);
    }
    fill(Color);
    for(int i = 1; i < optionsShowing; i++){
      line(x, y+(i*optionHeights), x+Width, y+(i*optionHeights));
    }
    textAlign(CENTER);
    textSize(FontSize);
    for(int i = 0; i < optionsShowing; i++){
      if (i < options.size()){
        fill(TextColor);
        text(options.get(i+scrollAmount), x+(Width/2), y+(i*(optionHeights)+optionHeights/1.5));
      }else{
        fill(BlankColor);
        rect(x + padding, y+(optionHeights*i)+padding, Width - 2*padding, optionHeights - 2*padding);
      }
    }
    fill(TextColor);
    stroke(Color);
    highlight(false);
  }  
}

class Panel extends GUI{
  Panel(float X, float Y, float Width, float Height, color Color){
    this.x = X;
    this.y = Y;
    this.Width = Width;
    this.Height = Height;
    this.Color = Color;
  }
  void update(){
    fill(Color);
    noStroke();
    rect(getX(), getY(), getWidth(), getHeight());
    stroke(color(0));
  }
}

class Image extends GUI{
  PImage image;
  Image(float x, float y, float Width, float Height){
    this.x = x;
    this.y = y;
    this.Width = Width;
    this.Height = Height;
  }
  void update(){
    tint(Color);
    image(image, x, y, Width, Height);
  }
}

class GUIGroup extends GUI{
  ArrayList<GUI> Elements = new ArrayList<GUI>();
  void update(){
    for(int i = 0; i < Elements.size(); i++){
      Elements.get(i).update();
    }
  }
  
  boolean WithinBounds(float X, float Y){
    return false;
  }
}