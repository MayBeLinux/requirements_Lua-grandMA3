local pluginName    = select(1,...);
local componentName = select(2,...); 
local signalTable   = select(3,...); 
local my_handle     = select(4,...);


signalTable.TextEditLoaded = function(caller,status,creator)
	
	-- Tabs
	local tab = caller.Frame.GenericTab;
	if (tab) then
		tab:AddListStringItem("Simple TextEdit", "MyTab1");
		tab:AddListStringItem("Plugin editor", "MyTab2");
		tab:SelectListItemByValue("MyTab1");
	end

	local text1 = "What is Lorem Ipsum?\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n";

	local text2 = "Where does it come from?\nContrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of 'de Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, comes from a line in section 1.10.32.\n\n";

	local text3 = "Why do we use it?\nIt is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).\n\n";

	local text4 = "Where can I get some?\nThere are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.\n";

	caller.Frame.DialogContainer.MyTab1.ContainerUnwrapped.Box.TextEdit.InsertText(text1);
	caller.Frame.DialogContainer.MyTab1.ContainerUnwrapped.Box.TextEdit.InsertText(text2);
	caller.Frame.DialogContainer.MyTab1.ContainerUnwrapped.Box.TextEdit.InsertText(text3);
	caller.Frame.DialogContainer.MyTab1.ContainerUnwrapped.Box.TextEdit.InsertText(text4);

	caller.Frame.DialogContainer.MyTab1.ContainerWrapped.Box.TextEdit.InsertText(text1);
	caller.Frame.DialogContainer.MyTab1.ContainerWrapped.Box.TextEdit.InsertText(text2);
	caller.Frame.DialogContainer.MyTab1.ContainerWrapped.Box.TextEdit.InsertText(text3);
	caller.Frame.DialogContainer.MyTab1.ContainerWrapped.Box.TextEdit.InsertText(text4);

	caller.Frame.DialogContainer.MyTab2.ContainerWrapped.Box.InputField.InsertText(text1);
	caller.Frame.DialogContainer.MyTab2.ContainerWrapped.Box.InputField.InsertText(text2);
	caller.Frame.DialogContainer.MyTab2.ContainerWrapped.Box.InputField.InsertText(text3);
	caller.Frame.DialogContainer.MyTab2.ContainerWrapped.Box.InputField.InsertText(text4);

end
