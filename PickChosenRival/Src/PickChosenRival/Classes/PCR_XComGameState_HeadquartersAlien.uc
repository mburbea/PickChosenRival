class PCR_XComGameState_HeadquartersAlien extends XComGameState_HeadquartersAlien;

var config name Assassin_Rival;
var config name Hunter_Rival;
var config name Warlock_Rival;
function SetUpAdventChosen(XComGameState StartState)
{
	local XComGameState_AdventChosen ChosenState;
	local int idx, RandIndex, i;
	local array<XComGameState_ResistanceFaction> AllFactions;
	local XComGameState_ResistanceFaction FactionState;
	local array<X2AdventChosenTemplate> AllChosen;
	local X2AdventChosenTemplate ChosenTemplate;
	local array<name> ExcludeStrengths, ExcludeWeaknesses;
	local bool bNarrative;
	local name cFaction;
	local name TemplateName;

	bNarrative = XComGameState_CampaignSettings(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings')).bXPackNarrativeEnabled;
	
	if(bNarrative)
	{
		super.SetUpAdventChosen(StartState);
		return;
	}

	// Grab Chosen Templates
	AllChosen = GetAllChosenTemplates();


	// Grab all faction states
	foreach StartState.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		AllFactions.AddItem(FactionState);
	}
	
	for(idx = 0; idx < default.NumAdventChosen; idx++)
	{
		cFaction = AllFactions[idx].GetMyTemplateName();
		if(cFaction == default.Assassin_Rival)
		{
			TemplateName = 'Chosen_Assassin';
		}
		else if(cFaction == default.Hunter_Rival)
		{
			TemplateName = 'Chosen_Hunter';
		}
		else if(cFaction == default.Warlock_Rival)
		{
			TemplateName='Chosen_Warlock';
		}
		else
		{
				TemplateName = '';
				break;
		}

		RandIndex = -1;
		for(i = 0; i < AllChosen.Length; i++)
		{
			if(AllChosen[i].DataName == TemplateName)
			{
				`log("Setting"@AllFactions[idx].GetMyTemplateName()@"against"@TemplateName,,'FixedChosenRivalries');
				RandIndex = i;
				break;
			}
		}
		if(TemplateName == '' || RandIndex == -1)
		{
			RandIndex = `SYNC_RAND(AllChosen.Length);
		}

		ChosenTemplate = AllChosen[RandIndex];
		ChosenState = ChosenTemplate.CreateInstanceFromTemplate(StartState);
		AdventChosen.AddItem(ChosenState.GetReference());
		AllChosen.Remove(RandIndex, 1);

		// Assign Rival Faction
		ChosenState.RivalFaction = AllFactions[idx].GetReference();
		AllFactions[idx].RivalChosen = ChosenState.GetReference();

		// Assign Traits
		ChosenState.AssignStartingTraits(ExcludeStrengths, ExcludeWeaknesses, AllFactions[idx], bNarrative);

		// Give them a name
		ChosenState.GenerateChosenName();

		//Generate an icon 
		ChosenState.GenerateChosenIcon();
	}
}
