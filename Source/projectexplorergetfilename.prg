*==============================================================================
* Function:			ProjectExplorerGetFileName
* Purpose:			Displays a file selection dialog
* Author:			Doug Hennig
* Last revision:	06/28/2018
* Parameters:		tcExtensions  - the extensions to use, using the format:
*						Description (*.ext1, *.ext2):EXT2,EXT2;
*						Description (*.ext1, *.ext2):EXT1,EXT2
*					tcFileName    - the default filename or default folder
*					tcCaption     - the caption for the dialog
*					tlSaveDialog  - .T. to display a save dialog
*					tnFilterIndex - the filter index to use (optional)
*					tlMultiSelect - .T. to allow multiple files to be selected
* Returns:			the filename chosen by the user or blank if none was chosen
*					(if tlMultiSelect is .T., the filenames are separated by
*					CR)
* Environment in:	ProjectExplorerCommonDialog.vcx is available
* Environment out:	none
*==============================================================================

lparameters tcExtensions, ;
	tcFileName, ;
	tcCaption, ;
	tlSaveDialog, ;
	tnFilterIndex, ;
	tlMultiSelect
local loCommonDialog, ;
	lnTypes, ;
	laTypes[1], ;
	lnI, ;
	lcExt, ;
	lnPos, ;
	lcDescrip, ;
	lcExten, ;
	lnExt, ;
	laExt[1], ;
	lnJ, ;
	lcFileName
#define ccCR chr(13)
loCommonDialog = newobject('ProjectExplorerCommonDialog', ;
	'ProjectExplorerCommonDialog.vcx')
with loCommonDialog
	do case
		case empty(tcFileName)
		case empty(justext(tcFileName))
			.cInitialDirectory = tcFileName
		otherwise
			.cFileName         = tcFileName
			.cInitialDirectory = justpath(tcFileName)
	endcase
	if not empty(tcCaption)
		.cTitleBarText = tcCaption
	endif not empty(tcCaption)
	.nFilterIndex = evl(tnFilterIndex, 0)
	.lAllowMultiSelect = tlMultiSelect

* Extensions are formatted as Description (*.ext):ext; Description (*.ext):ext
* If there are multiple extensions for a given type, format it as:
* Description (*.ext1, *.ext2):ext1,ext2; Description (*.ext):ext

	if not empty(tcExtensions)
		lnTypes = alines(laTypes, tcExtensions, .T., ';')
		.ClearFilters(.T.)
		for lnI = 1 to lnTypes
			lcExt = laTypes[lnI]
			if ':' $ lcExt
				lnPos     = at(':', lcExt)
				lcDescrip = alltrim(left(lcExt, lnPos - 1))
				lcExten   = alltrim(substr(lcExt, lnPos + 1))
			else
				lcDescrip = alltrim(lcExt)
				lcExten   = lcExt
			endif ':' $ lcExt

* There may be multiple extensions for this filter type, so handle that.

			lnExt   = alines(laExt, lcExten, .T., ',')
			lcExten = ''
			for lnJ = 1 to lnExt
				lcExten = lcExten + iif(empty(lcExten), '', ';') + '*.' + ;
					laExt[lnJ]
			next lnJ
			if .nFilterIndex = 0 and upper(justext(.cFileName)) $ upper(lcExten)
				.nFilterIndex = lnI
			endif .nFilterIndex = 0 ...
			.AddFilter(lcDescrip, lcExten)
		next lnI
	endif not empty(tcExtensions)
	.lSaveDialog = tlSaveDialog
	.ShowDialog()
	if tlMultiSelect
		lcFileName = ''
		for lnI = 1 to .nFileCount
			lcFileName = lcFileName + addbs(.cFilePath) + .aFileNames[lnI] + ;
				ccCR
		next lnI
	else
		lcFileName = addbs(.cFilePath) + .cFileTitle
	endif tlMultiSelect
endwith
return lcFileName
