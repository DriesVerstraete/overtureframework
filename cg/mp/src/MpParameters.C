#include "MpParameters.h"
#include "OGPolyFunction.h"
#include "OGTrigFunction.h"
#include "OGPulseFunction.h"
#include "Ogshow.h"
#include "PlotStuff.h"
#include "Interface.h"
#include "AdvanceOptions.h"
#include "DomainSolver.h"

int
addPrefix(const aString label[], const aString & prefix, aString cmd[], const int maxCommands);


//===================================================================================
//\begin{>ParametersInclude.tex}{\subsection{Variables in MpParameters}} 
//\no function header:
//
// /int numberOfDimensions: number of spacial dimensions.
//\end{ParametersInclude.tex}
//===================================================================================


//\begin{>>ParametersInclude.tex}{\subsection{Constructor}} 
MpParameters::
MpParameters(const int & numberOfDimensions0) : Parameters(numberOfDimensions0)
// ==================================================================================
//
//\end{ParametersInclude.tex}
//===================================================================================
{

  // list of different interfaces that we find: 
  if (!dbase.has_key("interfaceList")) dbase.put<InterfaceList>("interfaceList");

  // advance the domains in this order: 
  if (!dbase.has_key("domainOrder")) dbase.put<std::vector<int> >("domainOrder");

  // By default we set the initial domainOrder (e.g. so solid domains come first)
  if (!dbase.has_key("usePreferredOrderOfDomains")) dbase.put<bool>("usePreferredOrderOfDomains",false); // turn off for now

  if (!dbase.has_key("solveCoupledInterfaceEquations")) dbase.put<bool>("solveCoupledInterfaceEquations");
  dbase.get<bool>("solveCoupledInterfaceEquations")=true;  // default for explicit time stepping

  if (!dbase.has_key("useMixedInterfaceConditions")) dbase.put<bool>("useMixedInterfaceConditions");
  dbase.get<bool>("useMixedInterfaceConditions")=false;  // by default use Dirichlet-Neumann instead of mixed. 

  if (!dbase.has_key("activeInterface")) dbase.put<int>("activeInterface",-1);

  if (!dbase.has_key("interfaceTolerance")) dbase.put<real>("interfaceTolerance");
  dbase.get<real>("interfaceTolerance")=1.e-5;

  if (!dbase.has_key("interfaceOmega")) dbase.put<real>("interfaceOmega");
  dbase.get<real>("interfaceOmega")=1.;

  if (!dbase.has_key("extrapolateInitialInterfaceValues")) dbase.put<bool>("extrapolateInitialInterfaceValues",true);

  if (!dbase.has_key("numberOfInterfaceHistoryValuesToSave")) 
    dbase.put<int>("numberOfInterfaceHistoryValuesToSave");
  dbase.get<int>("numberOfInterfaceHistoryValuesToSave")=3;

  if (!dbase.has_key("numberOfInterfaceIterateValuesToSave")) 
    dbase.put<int>("numberOfInterfaceIterateValuesToSave");
  dbase.get<int>("numberOfInterfaceIterateValuesToSave")=3;

  if (!dbase.has_key("timeStepHasChanged")) dbase.put<bool>("timeStepHasChanged");
  dbase.get<bool>("timeStepHasChanged")=true;  // set to true when the time step is changed (used to re-initialize stuff)

  // By default we match interfaces geometrically as well as by the share and bc values:
  if (!dbase.has_key("matchInterfacesGeometrically")) dbase.put<bool>("matchInterfacesGeometrically",true); 

//   if (!dbase.has_key("domainPlotOption")) dbase.put<std::vector<PlotOptionEnum> >("domainPlotOption");

  if (!dbase.has_key("domainToPlot")) dbase.put<int>("domainToPlot",-1);
 
  // save interface convergence results here:
  if (!dbase.has_key("interfaceFile")) dbase.put<FILE*>("interfaceFile",NULL); 

  FILE *& interfaceFile =dbase.get<FILE* >("interfaceFile");
  interfaceFile = fopen("interfaceFile.log","w" );  
  
  // Set the following to true in order to use the new inteface transfer functions
  if (!dbase.has_key("useNewInterfaceTransfer")) dbase.put<bool>("useNewInterfaceTransfer");
  dbase.get<bool>("useNewInterfaceTransfer")=false;

  // There are different multi-domain time stepping algorithms:
  if (!dbase.has_key("multiDomainAlgorithm")) dbase.put<MultiDomainAlgorithmEnum>("multiDomainAlgorithm");
  dbase.get<MultiDomainAlgorithmEnum>("multiDomainAlgorithm")=defaultMultiDomainAlgorithm;

  // interfaceProjectionOption : 1=linear-FSR, 5=nonlinear-FSR
  if (!dbase.has_key("interfaceProjectionOption")) dbase.put<int>("interfaceProjectionOption");
  dbase.get<int>("interfaceProjectionOption")=1;

  // interfaceProjectionGhostOption : 0=extrapolate interface ghost points, 1=use-compatibility,
  //                                  2=use-exact-for-tz, 3=use-domain-bc
  if (!dbase.has_key("interfaceProjectionGhostOption")) dbase.put<int>("interfaceProjectionGhostOption");
  dbase.get<int>("interfaceProjectionGhostOption")=1;

  if (!dbase.has_key("relaxCorrectionSteps")) dbase.put<bool>("relaxCorrectionSteps")=false;

  // Here is where we save the maximum residual on each interface
  if( !dbase.has_key("maxResidual") ) dbase.put<std::vector<real> >("maxResidual");

  // Sometimes we need to iterate on the initial conditions (e.g. INS + deforming solids)
  if (!dbase.has_key("projectMultiDomainInitialConditions")) 
      dbase.put<bool>("projectMultiDomainInitialConditions")=false;

  // initialize the items that we time: 
  initializeTimings();
}

MpParameters::
~MpParameters()
{
  fclose( dbase.get<FILE* >("interfaceFile"));
}

int MpParameters::
setParameters(const int & numberOfDimensions0 /* =2 */,const aString & reactionName )
// ==================================================================================================
//  /reactionName (input) : optional name of a reaction oe a reaction 
//     file that defines the chemical reactions, such as
//      a Chemkin binary file. 
// ==================================================================================================
{

  printF("MpParameters::setParameters called...\n");
  Parameters::setParameters(numberOfDimensions0,reactionName);
  
  return 0;
}




// =====================================================================================
/// \brief Setup the stages in the multi-stage algorithm
// =====================================================================================
int MpParameters::
setupMultiStageAlgorithm(CompositeGrid & cg, DialogData & dialog )
{
  assert(  dbase.get<GenericGraphicsInterface* >("ps") !=NULL );
  GenericGraphicsInterface & gi = * dbase.get<GenericGraphicsInterface* >("ps");
  const std::vector<int> & domainOrder = dbase.get<std::vector<int> >("domainOrder");

  // enum TakeTimeStepOptionEnum
  // {
  //   takeStepAndApplyBoundaryConditions,
  //   takeStepButDoNotApplyBoundaryConditions,
  //   applyBoundaryConditionsOnly
  // };


  // Here is the vector of domainSolvers:
  std::vector<DomainSolver*> domainSolver = dbase.get<DomainSolver*>("domainSolver")->domainSolver; 

  // Here is a list of the stages in the multi-stage algorithm 
  if( !dbase.has_key("stageInfoList") )
  {
    std::vector<StageInfo> & stageInfoList = dbase.put<std::vector<StageInfo> >("stageInfoList");
    stageInfoList.clear();
  }

  std::vector<StageInfo> & stageInfoList = dbase.get<std::vector<StageInfo> >("stageInfoList");

  printF("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
         "+ Enter information defining the stages in the multi-domain algorithm.\n"
         "+ For each stage enter a line of the form (enter `done' when finished)\n"
         "+    actions=action1,action2,... classNames=[name,name,...] domainNames=[name,name,...]\n"
         "+ where \n"
         "+  action = [takeStep|applyBC]\n"
         "+  classNames = list of class names involved in his step, e.g. Cgsm, Cgins, Cgcns, Cgad.\n"
         "+             If a class name is given then all domains of this type will take part.\n"
         "+  domainNames = list of domain names (if not all domains in a class are involved).\n"
         "+ Examples:\n"
         "+     actions=takeStep classNames=Cgsm\n"
         "+     actions=takeStep,applyBC classNames=Cgins,Cgad\n"
         "+     actions=applyBC classNames=Cgins domainNames=solidDomain1,solidDomain2\n"
         "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
       );

  aString answer,prompt="Enter stage, done to finish";
  int numberOfStages=0;
  for( ;; )
  {
    gi.inputString(answer,prompt);
    if( answer=="done" )
    {
      break;
    }
    else
    {
      // --- add a new stage ---
      stageInfoList.push_back(StageInfo());
      StageInfo & stageInfo = stageInfoList[numberOfStages];  // new stage 

      // Parse the stage info 
      bool takeStep = answer.find("takeStep")!=std::string::npos;
      bool applyBC  = answer.find("applyBC")!=std::string::npos;
      
      if( takeStep && applyBC )
        stageInfo.action=AdvanceOptions::takeStepAndApplyBoundaryConditions;
      else if( takeStep )
        stageInfo.action=AdvanceOptions::takeStepButDoNotApplyBoundaryConditions;
      else if( applyBC )
        stageInfo.action=AdvanceOptions::applyBoundaryConditionsOnly;
      else
      {
        OV_ABORT("fix me");
      }

      // -- Look for classNames=....  (note may include domainNames later in the string but his shouldn't matter ...)
      aString classNames;
      size_t found=answer.find("classNames=");
      if( found!=std::string::npos )
        classNames = answer(found,answer.length());

      // bool updateCgsm  = classNames.find("Cgsm") !=std::string::npos;
      // bool updateCgins = classNames.find("Cgins")!=std::string::npos;
      // bool updateCgcns = classNames.find("Cgcns")!=std::string::npos;
      // bool updateCgad  = classNames.find("Cgad") !=std::string::npos;

      // -- Look for domainNames=.... 
      aString domainNames;
      found=answer.find("domainNames=");
      if( found!=std::string::npos )
        domainNames = answer(found,answer.length());

      // printF(" stage=%i: takeStep=%i applyBC=%i Cgsm=%i, Cgins=%i Cgcns=%i\n",
      //        numberOfStages,(int)takeStep,(int)applyBC,updateCgsm,updateCgins,updateCgcns);


      ForDomainOrdered(d)
      {
        aString className = domainSolver[d]->getClassName();
        aString domainName = cg.getDomainName(d);
        if( classNames.find(className)   !=std::string::npos ||
            domainNames.find(domainName) !=std::string::npos )
        {
          stageInfo.domainList.push_back(d);  // this domain takes part in this stage 
        }
        
        // if( updateCgsm && className=="Cgsm" )
        //   stageInfo.domainList.push_back(d);
        // if( updateCgins && className=="Cgins" )
        //   stageInfo.domainList.push_back(d);
        // if( updateCgcns && className=="Cgcns" )
        //   stageInfo.domainList.push_back(d);
        // if( updateCgad && className=="Cgad" )
        //   stageInfo.domainList.push_back(d);
      }
      numberOfStages++;
    }
  }

  // -- output a summary of the multi-stage algorithm --
  printF("\n  +-------------------------- MULT-STAGE ALGORITHM : numberOfStages=%i -----------------------\n",
           numberOfStages);
  for( int stage=0; stage<numberOfStages; stage++ )
  {
    StageInfo & stageInfo = stageInfoList[stage];
    bool takeStep = (stageInfo.action == AdvanceOptions::takeStepAndApplyBoundaryConditions ||
                     stageInfo.action == AdvanceOptions::takeStepButDoNotApplyBoundaryConditions);
    bool applyBCs = (stageInfo.action == AdvanceOptions::takeStepAndApplyBoundaryConditions ||
                     stageInfo.action == AdvanceOptions::applyBoundaryConditionsOnly );
    printF("  | stage=%d : takeStep=%i applyBCs=%i domains=[",
           stage,(int)takeStep,(int)applyBCs);
    for( int dd=0; dd<stageInfo.domainList.size(); dd++ )
    {
      int d=stageInfo.domainList[dd];
      printF(" domain=%d (%s:%s)",d,
             (const char*)(domainSolver[d]->getClassName()),
             (const char*)cg.getDomainName(d) );
      if( d<stageInfo.domainList.size()-1) printF(","); 
    }
    printF(" ]\n");
  }
  printF("  +------------------------------------------------------------------------------------------\n\n");

  // Set the interface communication mode -- 
  InterfaceCommunicationModeEnum & interfaceCommunicationMode= 
            dbase.get<InterfaceCommunicationModeEnum>("interfaceCommunicationMode");
  interfaceCommunicationMode=requestInterfaceDataWhenNeeded;
  ForDomainOrdered(d)
  { // Set modes in each domain 
    Parameters & par = domainSolver[d]->parameters;
    par.dbase.get<InterfaceCommunicationModeEnum>("interfaceCommunicationMode")=requestInterfaceDataWhenNeeded;
  }
  
  return 0;
}


int MpParameters::
setPdeParameters(CompositeGrid & cg, const aString & command /* = nullString */,
                 DialogData *interface /* =NULL */ )
// =====================================================================================
// /Description:
//   Prompt for changes in the PDE parameters.
// =====================================================================================
{
  int returnValue=0;

  assert(  dbase.get<GenericGraphicsInterface* >("ps") !=NULL );
  GenericGraphicsInterface & gi = * dbase.get<GenericGraphicsInterface* >("ps");

  aString prefix = "OBPDE:"; // prefix for commands to make them unique.

  // ** Here we only look for commands that have the proper prefix ****
  const bool executeCommand = command!=nullString;
  if( executeCommand && command(0,prefix.length()-1)!=prefix && command!="build dialog" )
    return 1;

  aString answer;
  char buff[100];

  bool useNonlinearInterfaceProjection=dbase.get<int >("interfaceProjectionOption")==5;

  int & interfaceProjectionGhostOption = dbase.get<int>("interfaceProjectionGhostOption");
  bool & relaxCorrectionSteps= dbase.get<bool>("relaxCorrectionSteps");
  MultiDomainAlgorithmEnum & multiDomainAlgorithm = dbase.get<MultiDomainAlgorithmEnum>("multiDomainAlgorithm");
  
  GUIState gui;
  gui.setExitCommand("done", "continue");
  DialogData & dialog = interface!=NULL ? *interface : (DialogData &)gui;

  if( interface==NULL || command=="build dialog" )
  {
    const int maxCommands=40;
    aString cmd[maxCommands];
    dialog.setWindowTitle("Multi-physics parameters");

    dialog.setOptionMenuColumns(1);

    // --- options for multi-domain advance:
    aString opCmd[] = {"default advance", 
		       "step all then match advance" ,
                       "multi-stage",
		       "" };
    addPrefix(opCmd,prefix,cmd,maxCommands);
    dialog.addOptionMenu("Multi-domain advance", cmd, opCmd,multiDomainAlgorithm);

    // --- options for setting ghost points with the interface projection ---
    aString opCmd2[] = {"interface ghost from extrapolation", 
			"interface ghost from compatibility" ,
			"interface ghost from exact" ,
                        "interface ghost from domain solvers",
			"" };
    addPrefix(opCmd2,prefix,cmd,maxCommands);
    dialog.addOptionMenu("Interface ghost:", cmd, opCmd2,interfaceProjectionGhostOption);

    aString pbLabels[] = {"show interface parameters",
			    ""};
    addPrefix(pbLabels,prefix,cmd,maxCommands);

    int numRows=3;
    dialog.setPushButtons( cmd, pbLabels, numRows ); 


    aString tbLabels[] = {"solve coupled interface equations",
                          "use mixed interface conditions",
                          "extrapolate initial interface values",
                          "use new interface transfer",
                          "project interface",
                          "use nonlinear interface projection",
                          "relax correction steps",
                          "project initial conditions",
			    ""};
    int tbState[10];
    tbState[0] = dbase.get<bool>("solveCoupledInterfaceEquations");
    tbState[1] = dbase.get<bool>("useMixedInterfaceConditions");
    tbState[2] = dbase.get<bool>("extrapolateInitialInterfaceValues");
    tbState[3] = dbase.get<bool>("useNewInterfaceTransfer");
    tbState[4] = dbase.get<bool>("projectInterface");
    tbState[5] = useNonlinearInterfaceProjection;
    tbState[6] = relaxCorrectionSteps;
    tbState[7] = dbase.get<bool>("projectMultiDomainInitialConditions");
    
    int numColumns=1;
    addPrefix(tbLabels,prefix,cmd,maxCommands);
    dialog.setToggleButtons(cmd, tbLabels, tbState, numColumns); 


    const int numberOfTextStrings=10;
    aString textLabels[numberOfTextStrings];
    aString textStrings[numberOfTextStrings];

    int nt=0;
    textLabels[nt] = "active interface";  sPrintF(textStrings[nt], "%i (-1=all, for params)", 
                      dbase.get<int >("activeInterface"));  nt++; 
 
    textLabels[nt] = "interface tolerance";  sPrintF(textStrings[nt], "%g", 
                      dbase.get<real >("interfaceTolerance"));  nt++; 
 
    textLabels[nt] = "interface omega";  sPrintF(textStrings[nt], "%g", 
                      dbase.get<real >("interfaceOmega"));  nt++; 
 
    textLabels[nt] = "domain order"; textStrings[nt]="";
    std::vector<int> & domainOrder = dbase.get<std::vector<int> >("domainOrder");
    for( int d=0; d<domainOrder.size(); d++ )
    {
      textStrings[nt] += sPrintF("%i ",domainOrder[d]);
    }
    nt++;
    
    // textLabels[nt] = "dtMax";  sPrintF(textStrings[nt], "%g",dbase.get<real >("dtMax"));  nt++; 
 
    // null strings terminal list
    textLabels[nt]="";   textStrings[nt]="";  assert( nt<numberOfTextStrings );
    addPrefix(textLabels,prefix,cmd,maxCommands);
    dialog.setTextBoxes(cmd, textLabels, textStrings);

    if( false && gi.graphicsIsOn() )
      dialog.openDialog(0);   // open the dialog here so we can reset the parameter values below

    updatePDEparameters();

    if( executeCommand ) return 0;
  }
  
  if( !executeCommand  )
  {
    gi.pushGUI(gui);
    gi.appendToTheDefaultPrompt("pde parameters>");  
  }

  InterfaceList & interfaceList = dbase.get<InterfaceList>("interfaceList");
  int & activeInterface = dbase.get<int>("activeInterface");
  
  int len;
  for(int it=0; ; it++)
  {
    if( !executeCommand )
    {
      gi.getAnswer(answer,"");
    }
    else
    {
      if( it==0 ) 
        answer=command;
      else
        break;
    }
  
    if( answer(0,prefix.length()-1)==prefix )
      answer=answer(prefix.length(),answer.length()-1);   // strip off the prefix

    printF("setPdeParameters: answer=[%s]\n",(const char*)answer);
    

    if( answer=="done" )
      break;
    else if( dialog.getTextValue(answer,"active interface","%i", activeInterface) )
    {
      printF("Setting the active interface to %i (for setting parameters, -1=all)\n",activeInterface);
    }
    else if( dialog.getTextValue(answer,"interface tolerance","%e", dbase.get<real>("interfaceTolerance")) )
    {
      if( activeInterface==-1 )
	printF("Setting the interfaceTolerance=%8.2e for all %i interfaces\n",dbase.get<real>("interfaceTolerance"),
	       interfaceList.size());
      else
        printF("Setting the interfaceTolerance=%8.2e for interface %i.\n",dbase.get<real>("interfaceTolerance"),
                activeInterface);
      for( int inter=0; inter < interfaceList.size(); inter++ )
      {
        if( activeInterface==-1 || activeInterface==inter )
	{
	  InterfaceDescriptor & interfaceDescriptor = interfaceList[inter]; 
	  interfaceDescriptor.interfaceTolerance=dbase.get<real>("interfaceTolerance");
	}
      }
    }
    else if( dialog.getTextValue(answer,"interface omega","%e", dbase.get<real>("interfaceOmega")) )
    {
      if( activeInterface==-1 )
	printF("Setting the interfaceOmega=%8.2e for all %i interfaces\n",dbase.get<real>("interfaceOmega"),
	       interfaceList.size());
      else
	printF("Setting the interfaceOmega=%8.2e for interface %i.\n",dbase.get<real>("interfaceOmega"),
	       activeInterface);

      for( int inter=0; inter < interfaceList.size(); inter++ )
      {
        if( activeInterface==-1 || activeInterface==inter )
	{
	  InterfaceDescriptor & interfaceDescriptor = interfaceList[inter]; 
	  interfaceDescriptor.interfaceOmega=dbase.get<real>("interfaceOmega");
	}
      }
    }
    else if( dialog.getToggleValue(answer,"solve coupled interface equations",
                                   dbase.get<bool>("solveCoupledInterfaceEquations")) ){} //
    else if( dialog.getToggleValue(answer,"use mixed interface conditions",
                                   dbase.get<bool>("useMixedInterfaceConditions")) ){} //
    else if( dialog.getToggleValue(answer,"extrapolate initial interface values",
                                   dbase.get<bool>("extrapolateInitialInterfaceValues")) ){} //
    else if( dialog.getToggleValue(answer,"use new interface transfer",
                                   dbase.get<bool>("useNewInterfaceTransfer")) ){} //
    else if( dialog.getToggleValue(answer,"project interface",
                                   dbase.get<bool>("projectInterface")) ){} //
    else if( dialog.getToggleValue(answer,"use nonlinear interface projection",useNonlinearInterfaceProjection) )
    {
      if( useNonlinearInterfaceProjection )
	dbase.get<int >("interfaceProjectionOption")=5;
    }
    else if( dialog.getToggleValue(answer,"relax correction steps",relaxCorrectionSteps) ){} // 
    // else if( dialog.getTextValue(answer,"dtMax","%e",dbase.get<real >("dtMax")) ){} //

    else if( dialog.getToggleValue(answer,"project initial conditions",
        dbase.get<bool>("projectMultiDomainInitialConditions")) ){} // 

    else if( len=answer.matches("domain order") )
    {
      std::vector<int> & domainOrder = dbase.get<std::vector<int> >("domainOrder");
      bool ok=true;
      for( int d=0; d<domainOrder.size(); d++ )
      {
        int domain=-1;
        const int length = answer.length();
	while( len<length && answer[len]==' ' ) len++;  // skip blanks
	int numChars = sScanF(answer(len,answer.length()-1),"%i",&domain);
	len+=numChars;
	if( domain>=0 && domain<domainOrder.size() )
	{
          domainOrder[d]=domain;
	}
	else
	{
          printF("Error: invalid domain number=%i\n",domain);
	  ok=false;
          gi.stopReadingCommandFile();
	  break;
	}
	
      }
      if( !ok )
      {
	printF("I am reseting the domain order to the default.\n");
	for( int d=0; d<domainOrder.size(); d++ ) domainOrder[d]=d;
      }
      else
      {
        // We should also check that all domains are accounted for
	printF(" New domainOrder = ");
	for( int d=0; d<domainOrder.size(); d++ )
	{
	  printF("%i ",domainOrder[d]);
	}
	printF("\n");
      }
    }
    else if( answer == "show interface parameters" )
    {
      displayInterfaceInfo();
    }
    else if(  dbase.get<ListOfShowFileParameters >("pdeParameters").matchAndSetValue( answer ) )
    {
      printF("*** answer=[%s] was found as a user defined parameter\n",(const char*)answer);
      
    }
    else if( answer=="default advance" ||
             answer=="step all then match advance" ||
             answer=="multi-stage" )
    {
      if( answer=="default advance" )
      {
	multiDomainAlgorithm=defaultMultiDomainAlgorithm;
      }
      else if( answer=="step all then match advance" )
      {
	multiDomainAlgorithm=stepAllThenMatchMultiDomainAlgorithm;
        printF("Setting multiDomainAlgorithm=stepAllThenMatchMultiDomainAlgorithm\n");
      }
      else if( answer=="multi-stage" )
      {
        multiDomainAlgorithm=multiStageAlgorithm;
        printF("Setting multiDomainAlgorithm=multiStageAlgorithm\n");

        // setup the stages in the multi-stage algorithm
        setupMultiStageAlgorithm(cg,dialog);
        
      }
      
      else
      {
	OV_ABORT("ERROR: unexpected answer");
      }
    }

    else if( answer=="interface ghost from extrapolation" ||
             answer=="interface ghost from compatibility" ||
             answer=="interface ghost from exact" ||
             answer=="interface ghost from domain solvers" )
    {
      interfaceProjectionGhostOption = (answer=="interface ghost from extrapolation" ? 0 :
                                        answer=="interface ghost from compatibility" ? 1 :
                                        answer=="interface ghost from exact" ? 2 : 3);
      if( interfaceProjectionGhostOption==0 )
      {
	printF("Ghost points at interfaces will be extrapolated (this only applies to the fluid-solid projection scheme).\n");
      }
      else if( interfaceProjectionGhostOption==1 )
      {
	printF("Ghost points at interfaces will be obtained from compatibility conditions (this only applies to the fluid-solid projection scheme).\n");
      }
      else if( interfaceProjectionGhostOption==2 )
      {
	printF("Ghost points at interfaces will be set to exact values (for testing with TZ only).\n");
      }
      else
      {
	printF("Ghost points at interfaces will be set from domain solver BC routines (e.g. cgcns, cgsm, cgins).\n");
      }
      
      
    }

    else
    {
      if( executeCommand )
      {
	returnValue= 1;  // when executing  dbase.get<real >("a") single command, return 1 if the command was not recognised.
        break;
      }
      else
      {
	printF("Unknown response=[%s]\n",(const char*)answer);
	gi.stopReadingCommandFile();
      }
       
    }

  }

  if( !executeCommand  )
  {
    gi.popGUI();
    gi.unAppendTheDefaultPrompt();
  }

 return returnValue;

}



int MpParameters::
displayPdeParameters(FILE *file /* = stdout */ )
// =====================================================================================
// /Description:
//   Display PDE parameters
// =====================================================================================
{
  const char *offOn[2] = { "off","on" };

  fPrintF(file,
	  "PDE parameters: equation is `multi-physics'.\n");

  // The  dbase.get<DataBase >("modelParameters") will be displayed here:
  Parameters::displayPdeParameters(file);

  fPrintF(file,
	  "  interface tolerance = %e\n"
	  "  interface omega=%e\n",
	   dbase.get<real >("interfaceTolerance"),
	   dbase.get<real >("interfaceOmega"));

  return 0;
}


// =================================================================================================
/// \brief Print a summary of information about the interfaces.
// =================================================================================================
int MpParameters::
displayInterfaceInfo(FILE *file /* = stdout */ )
{
  InterfaceList & interfaceList = dbase.get<InterfaceList>("interfaceList");
  for( int inter=0; inter < interfaceList.size(); inter++ )
  {
    InterfaceDescriptor & interfaceDescriptor = interfaceList[inter]; 
    fPrintF(file,
	    "Interface %i : tol=%9.3e, omega=%9.3e, max iterations=%i, ave-CR=%8.2e, ave-Its=%i\n",
	    inter,
	    interfaceDescriptor.interfaceTolerance,
	    interfaceDescriptor.interfaceOmega,
	    interfaceDescriptor.maximumNumberOfIntefaceIterations,
	    interfaceDescriptor.estimatedConvergenceRate/max(1,interfaceDescriptor.numberOfInterfaceSolves),
	    interfaceDescriptor.totalNumberOfInterfaceIterations/max(1,dbase.get<int >("globalStepNumber")));
  }
  return 0;
}



//\begin{>>MpParametersInclude.tex}{\subsection{updateShowFile}} 
int MpParameters::
saveParametersToShowFile()
// =================================================================================================
// /Description:
//     Save PDE specific parameters in the show file.
//     These parameters can be used for a restart. They can also be used, for example,
//     by the user defined derived functions (when viewing the show file with plotStuff).
// 
//\end{MpParametersInclude.tex}  
// =================================================================================================
{
  printF("MpParameters:: saveParametersToShowFile called...\n");

  assert(  dbase.get<Ogshow* >("show")!=NULL );

  ListOfShowFileParameters & showFileParams = dbase.get<ListOfShowFileParameters>("showFileParams");

  // save parameters
    
  showFileParams.push_back(ShowFileParameter("interfaceTolerance", dbase.get<real >("interfaceTolerance")));
  showFileParams.push_back(ShowFileParameter("interfaceOmega", dbase.get<real >("interfaceOmega")));
  
  // Now save parameters common to all solvers:
  Parameters::saveParametersToShowFile();    

  return 0;
}


